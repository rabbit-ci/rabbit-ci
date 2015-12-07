defmodule BuildMan.ConfigExtractionSup do
  import BuildMan.FileHelpers, only: [unique_folder: 1]
  import BuildMan.GitHelpers
  alias RabbitCICore.Repo
  alias RabbitCICore.Build
  require Logger
  use GenServer
  use AMQP

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @exchange Application.get_env(:build_man, :config_extraction_exchange)
  @queue Application.get_env(:build_man, :config_extraction_queue)
  @worker_limit Application.get_env(:build_man, :config_extraction_limit)

  def init(:ok) do
    open_chan = RabbitMQ.with_conn fn conn ->
      {:ok, chan} = Channel.open(conn)

      Basic.qos(chan, prefetch_count: @worker_limit)
      Queue.declare(chan, @queue, durable: true)
      Exchange.fanout(chan, @exchange, durable: true)
      Queue.bind(chan, @queue, @exchange)

      {:ok, _consumer_tag} = Basic.consume(chan, @queue)
      {:ok, chan}
    end

    case open_chan do
      {:ok, chan} ->
        {:ok, chan}
      {:error, :disconnected} ->
        {:stop, :disconnected}
    end
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, _}, chan) do
    Logger.info("#{__MODULE__} connected to RabbitMQ.")
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as
  # after a queue deletion)
  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}

  def handle_info({:basic_deliver, payload,
                   %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    Task.start_link fn ->
      :erlang.process_flag(:trap_exit, true)

      Task.start_link fn ->
        consume(chan, tag, redelivered, payload)
      end

      receive do
        {:EXIT, _pid, _reason} ->
          if Process.alive?(chan.pid), do: Basic.ack(chan, tag)
          BuildMan.FileExtraction.finish
      end
    end
    {:noreply, chan}
  end

  defp consume(channel, _tag, _redelivered, packed_payload) do
    payload = Map.merge(%{file: ".rabbitci.yaml"},
                        :erlang.binary_to_term(packed_payload))

    Logger.debug "Extracting config. Payload: #{inspect payload}"
    {:ok, path} = unique_folder("rabbits")

    try do
      clone_repo(path, payload)

      contents =
        Path.join([path, payload.file])
        |> File.read!

      BuildMan.FileExtraction.reply(payload.file, contents, payload.build_id,
                                    payload)
    rescue
      e ->
        Repo.get(Build, payload.build_id)
        |> Build.changeset(%{config_extracted: "error"})
        |> Repo.update!
        raise e
    after
      File.rm_rf!(path)
      case Repo.get(Build, payload.build_id) do
        build = %Build{config_extracted: "false"} ->
          build
          |> Build.changeset(%{config_extracted: "true"})
          |> Repo.update!
        _ -> nil
      end
    end
  end
end

defmodule BuildMan.FileExtraction do
  require Logger
  alias BuildMan.ProjectConfig

  def reply(name, contents, build_id, payload)
  when is_binary(name) and is_binary(contents) do
    Logger.debug """
    Got file #{name}, contents:\n\n    #{
      String.split(contents, "\n") |> Enum.join("\n    ")
    }"
    """

    contents
    |> ProjectConfig.parse_from_yaml
    |> ProjectConfig.queue_builds(build_id, payload)
  end

  def finish do
    Logger.debug "Finished Extracting config"
  end
end
