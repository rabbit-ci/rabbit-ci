defmodule BuildSup do
  require Logger
  use GenServer
  use AMQP

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange "rabbitci_build_exchange"
  @queue "rabbitci_build_queue"

  def init(_opts) do
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
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:ok, hostname} = :inet.gethostname
    Logger.info("BuildSup started on #{hostname}")
    {:noreply, chan}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as
  # after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_deliver, payload,
                   %{delivery_tag: tag, redelivered: redelivered}}, chan) do
    spawn fn -> consume(chan, tag, redelivered, payload) end
    {:noreply, chan}
  end

  defp consume(channel, tag, redelivered, payload) do
    Logger.debug "Extracting config. Payload: #{payload}"

    {:ok, path} = unique_folder("rabbits")
    git = System.find_executable("git")
    ExExec.run([git, "clone", "git@github.com:octocat/Spoon-Knife.git", path],
               [:sync, :stdout, :stderr])
    {:ok, contents} = File.read("#{path}/README.md")
    File.rm_rf!(path)
    Basic.ack(channel, tag)
    Logger.debug "Finished Extracting config. Payload: #{payload}"
  end

  defp unique_folder(prefix \\ "") do # TODO: Extract to shared module
    system_tmp = System.tmp_dir
    unique_hash = :erlang.phash2(make_ref)
    tmp_path = "#{system_tmp}RabbitCI/#{prefix}#{unique_hash}"
    case File.mkdir_p(tmp_path) do
      :ok -> {:ok, tmp_path}
      a = {:error, _} -> a
    end
  end
end
