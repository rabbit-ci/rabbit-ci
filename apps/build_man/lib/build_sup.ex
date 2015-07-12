defmodule BuildSup do
  require Logger
  use GenServer
  use AMQP

  def start_link(option) do
    GenServer.start_link(__MODULE__, option, [])
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
    IO.puts "Payload: #{payload}"
    Basic.ack(channel, tag)
  end
end
