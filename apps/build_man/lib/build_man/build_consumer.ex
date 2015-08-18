defmodule BuildMan.BuildConsumer do
  @exchange "rabbitci_builds_build_exchange"
  @queue "rabbitci_builds_build_queue"

  use AMQP
  use GenServer
  alias BuildMan.Vagrant
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    open_chan = RabbitMQ.with_conn fn conn ->
      {:ok, chan} = Channel.open(conn)

      Basic.qos(chan, prefetch_count: 2) # TODO: Config this per node.
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

  # AMQP Stuff
  def handle_info({:basic_consume_ok, _}, state) do
    {:ok, hostname} = :inet.gethostname
    Logger.info("BuildMan.BuildProcessor started on #{hostname}")
    {:noreply, state}
  end

  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}

  def handle_info({:basic_deliver, payload,
                   %{delivery_tag: tag, routing_key: routing_key}}, chan)
  do
    Logger.debug("Starting build...")
    spawn fn ->
      :erlang.process_flag(:trap_exit, true)

      # [identifier, config]
      Vagrant.start_link([inspect(tag), :erlang.binary_to_term(payload)])

      receive do
        {:EXIT, _pid, :normal} -> Basic.ack(chan, tag)
        {:EXIT, _pid, _} -> Basic.reject(chan, tag, requeue: false)
      end
    end

    {:noreply, chan}
  end
end
