defmodule BuildMan.Build do
  defstruct build_id: nil, cancelled: false, repo: nil, commit: nil, pr: nil
end

defmodule BuildMan.BuildSup do
  require Logger
  import BuildMan.FileHelpers, only: [unique_folder: 1]
  import BuildMan.GitHelpers
  use GenServer
  use AMQP

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  @exchange "rabbitci_build_exchange"
  @queue "rabbitci_build_queue"

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
    clone_repo(path, payload)
    {:ok, contents} = File.read("#{path}/README.md")
    File.rm_rf!(path)
    Basic.ack(channel, tag) # We need to nack if it explodes.
    Logger.debug "Finished Extracting config. Payload: #{inspect payload}"
  end
end


defmodule TBC do
  def run do
    term = :erlang.term_to_binary(%{"repo" => "git@github.com:rabbit-ci/backend.git",
                                    "commit" => "cbc19a1c910ce86716ebbc7434b627d305733ef1"})
    {:ok, conn} = AMQP.Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = AMQP.Channel.open(conn)
    AMQP.Basic.publish(chan, "rabbitci_build_exchange", "", term) # persistent?
  end
end
