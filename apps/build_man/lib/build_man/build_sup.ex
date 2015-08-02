defmodule BuildMan.BuildSup do
  require Logger
  import BuildMan.FileHelpers, only: [unique_folder: 1]
  import BuildMan.GitHelpers
  use GenServer
  use AMQP

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @exchange "rabbitci_builds_file_extraction_exchange"
  @queue "rabbitci_builds_file_extraction_queue"

  def init(:ok) do
    {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = Channel.open(conn)

    Basic.qos(chan, prefetch_count: 1) # TODO: Config this per node.
    Queue.declare(chan, @queue, durable: true)
    Exchange.fanout(chan, @exchange, durable: true)
    Queue.bind(chan, @queue, @exchange)

    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:ok, chan}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:ok, hostname} = :inet.gethostname
    Logger.info("BuildMan.BuildSup started on #{hostname}")
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as
  # after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload,
                   %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn fn ->
      :erlang.process_flag(:trap_exit, true)

      spawn_link fn ->
        consume(chan, tag, redelivered, payload)
      end

      receive do
        {:EXIT, _pid, :normal} -> nil
        {:EXIT, _pid, _} -> Basic.reject(chan, tag, requeue: false)
      end
    end
    {:noreply, chan}
  end

  defp consume(channel, tag, _redelivered, packed_payload) do
    payload = :erlang.binary_to_term(packed_payload)
    Logger.debug "Extracting config. Payload: #{inspect payload}"
    {:ok, path} = unique_folder("rabbits")

    try do
      clone_repo(path, payload)

      contents =
        Path.join([path, payload.file])
      |> File.read!

      BuildMan.FileExtraction.reply(payload.file, contents)
    after
      File.rm_rf!(path)
    end

    Basic.ack(channel, tag)
    BuildMan.FileExtraction.finish
  end
end

defmodule BuildMan.FileExtraction do
  require Logger

  def reply(name, contents) when is_binary(name) and is_binary(contents) do
    contents = String.split(contents, "\n") |> Enum.join("\n    ")
    Logger.debug "Got file #{name}, contents:\n\n    #{contents}"
  end

  def finish do
    Logger.debug "Finished Extracting config"
  end
end
