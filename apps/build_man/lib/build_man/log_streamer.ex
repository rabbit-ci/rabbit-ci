defmodule BuildMan.LogStreamer do
  @moduledoc """
  A GenServer for dealing with logs from Builds.
  """

  require Logger
  use AMQP
  use GenServer
  alias BuildMan.RabbitMQ
  alias BuildMan.LogProcessor

  # Client API
  @doc """
  Starts the log streamer. `opts` must be a tuple in the format:

      {pid, build_identifier}

  With the values being:

  `pid`: The pid of the process that should be monitored. When that process
  shuts down, the LogStreamer will finish processing the messages in the queue
  and shut down as well. This should generally be the return value of `self/1`.

  `build_identifier`: A unique identifier for the build. This is use to
  determine the routing key to bind the queue.
  """
  def start(opts) do
    Logger.debug("Starting up LogStreamer...")
    GenServer.start(__MODULE__, opts)
  end

  @exchange "rabbitci_builds_logs"

  def log_string(str, type, build_identifier) do
    # publish(exchange, routing_key, payload, options \\ [])
    RabbitMQ.publish(@exchange, "#{type}.#{build_identifier}", str)
  end

  # Server callbacks
  def init({ref, build_identifier}) do
    Process.monitor(ref)

    open_chan = RabbitMQ.with_conn fn conn ->
      {:ok, chan} = Channel.open(conn)
      Basic.qos(chan, prefetch_count: 10)
      {:ok, %{queue: queue}} = Queue.declare(chan, "", auto_delete: true)
      Exchange.topic(chan, @exchange)
      Queue.bind(chan, "", @exchange, routing_key: "#.#{build_identifier}")

      {:ok, _consumer_tag} = Basic.consume(chan, queue)
      {:ok, {chan, ref, false, queue}}
    end

    case open_chan do
      {:ok, state = {%{pid: pid}, _, _, _}} ->
        Process.monitor(pid)
        {:ok, state}
      {:error, :disconnected} ->
        {:stop, :disconnected}
    end
  end

  # AMQP Stuff
  def handle_info({:basic_consume_ok, _}, state) do
    {:ok, hostname} = :inet.gethostname
    Logger.info("BuildMan.LogStreamer started on #{hostname}")
    {:noreply, state}
  end

  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}

  def handle_info({:basic_deliver, payload,
                   %{delivery_tag: tag, routing_key: routing_key}},
                  state = {chan, ref, stop, queue}) do
    Basic.ack(chan, tag)
    count = Queue.message_count(chan, queue)
    process_message(payload, count, stop, routing_key, state)
  end

  defp process_message(payload, 0, true, routing_key, state) do
    LogProcessor.process(payload, routing_key)
    shut_down(state)
  end

  defp process_message(payload, _, _, routing_key, state) do
    LogProcessor.process(payload, routing_key)
    {:noreply, state}
  end

  # This is what is called when the process we were monitoring dies. If the
  # queue is empty, we shut down. If not, we set the third value in the state
  # tuple to true which will be picked up on the next processed message.
  def handle_info({:DOWN, ref, :process, _pid, _reason},
                  {chan, ref2, _stop, queue}) when ref == ref2 do
    case Queue.message_count(chan, queue) do
      0 -> shut_down({chan, ref2, true, queue})
      _ -> {:noreply, {chan, ref2, true, queue}}
    end
  end

  # Channel died.
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state) do
    case _reason do
      :normal -> Logger.debug("RabbitMQ Channel shut down")
      _ -> Logger.warn("RabbitMQ Channel died!")
    end
    shut_down(state)
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp shut_down(state) do
    Logger.debug("Log streamer going down... #{inspect state}")
    {:stop, :normal, state}
  end

  def terminate(_reason, {chan, _, _, _}) do
    try do
      Channel.close(chan)
    catch
      _, _ -> :ok
    end
  end
end

defmodule BuildMan.LogProcessor do
  require Logger

  def process(payload, "stderr." <> identifier) do
    Logger.debug "STDERR (#{identifier}): #{payload}"
    # Do something
  end

  def process(payload, "stdout." <> identifier) do
    Logger.debug "STDOUT (#{identifier}): #{payload}"
    # Do something
  end
end
