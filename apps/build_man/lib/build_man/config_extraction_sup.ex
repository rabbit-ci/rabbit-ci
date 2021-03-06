defmodule BuildMan.ConfigExtractionSup do
  import BuildMan.FileHelpers, only: [unique_folder: 1]
  alias BuildMan.GitHelpers
  alias RabbitCICore.Repo
  alias RabbitCICore.Build
  alias RabbitCICore.SSHKey
  alias BuildMan.ProjectConfig
  alias RabbitCICore.RecordPubSubChannel, as: PubSub
  require Logger
  use GenServer
  use AMQP
  use BuildMan.RabbitMQMacros

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @processor Application.get_env(:build_man, :config_extraction_processor, __MODULE__)
  @exchange Application.get_env(:build_man, :config_extraction_exchange)
  @queue Application.get_env(:build_man, :config_extraction_queue)
  @worker_limit Application.get_env(:build_man, :config_extraction_limit)

  def rabbitmq_connect(_opts) do
    RabbitMQ.with_conn fn conn ->
      {:ok, chan} = Channel.open(conn)
      Basic.qos(chan, prefetch_count: @worker_limit)
      Queue.declare(chan, @queue, durable: true)
      Exchange.fanout(chan, @exchange, durable: true)
      Queue.bind(chan, @queue, @exchange)

      {:ok, _consumer_tag} = Basic.consume(chan, @queue)
      {:ok, %{chan: chan}}
    end
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, _}, state) do
    Logger.info("#{__MODULE__} connected to RabbitMQ.")
    {:noreply, state}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as
  # after a queue deletion)
  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag}}, state = %{chan: chan}) do
    Task.start_link fn ->
      :erlang.process_flag(:trap_exit, true)

      Task.start_link fn -> consume(payload) end

      receive do
        {:EXIT, _pid, _reason} ->
          if Process.alive?(chan.pid), do: Basic.ack(chan, tag)
          @processor.done
      end
    end
    {:noreply, state}
  end

  defp consume(packed_payload) do
    payload = Map.merge(%{file: ".rabbitci.json"},
                        :erlang.binary_to_term(packed_payload))

    Logger.debug "Extracting config. Payload: #{inspect payload}"
    {:ok, path} = unique_folder("rabbits")

    try do
      ssh_key = SSHKey.private_key_from_build_id(payload.build_id)
      clone_repo(path, payload, ssh_key)

      contents =
        Path.join([path, payload.file])
        |> File.read!

      @processor.process_config(payload.file, contents, payload.build_id, payload)
    rescue
      e ->
        Repo.get(Build, payload.build_id)
        |> Build.changeset(%{config_extracted: "error"})
        |> Repo.update!
        |> PubSub.update_build
        raise e
    after
      File.rm_rf!(path)
      case Repo.get(Build, payload.build_id) do
        build = %Build{config_extracted: "false"} ->
          build
          |> Build.changeset(%{config_extracted: "true"})
          |> Repo.update!
          |> PubSub.update_build
        _ -> nil
      end
    end
  end

  defp clone_repo(path, payload, nil), do: GitHelpers.clone_repo(path, payload)
  defp clone_repo(path, payload, ssh_key) do
    GitHelpers.clone_repo_with_ssh_key(path, payload, ssh_key)
  end

  # Payload includes pr/commit.
  def process_config(name, contents, build_id, payload)
  when is_binary(name) and is_binary(contents) do
    Logger.debug """
    Got file #{name}, contents:\n\n    #{
      String.split(contents, "\n") |> Enum.join("\n    ")
    }"
    """

    contents
    |> ProjectConfig.parse_from_json
    |> ProjectConfig.queue_builds(build_id, payload)
  end

  def done, do: Logger.debug("Finished Extracting config")
end
