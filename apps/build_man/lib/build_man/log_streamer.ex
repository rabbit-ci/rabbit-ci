defmodule BuildMan.LogStreamer do
  @moduledoc """
  A GenServer for dealing with logs from Builds.
  """

  require Logger
  use AMQP
  use GenServer
  alias BuildMan.LogProcessor
  alias BuildMan.LogOutput

  # Client API
  @doc """
  Starts the log streamer.
  """
  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @exchange Application.get_env(:build_man, :build_logs_exchange)
  @queue Application.get_env(:build_man, :build_logs_queue)
  @log_streamer_limit Application.get_env(:build_man, :log_streamer_limit)

  def log_string(str, type, order, step_id) do
    map = %LogOutput{text: str, order: order, step_id: step_id, type: type}
    RabbitMQ.publish(@exchange, "#{type}.#{step_id}",
                     :erlang.term_to_binary(map))
  end

  # Server callbacks
  def init([]) do
    open_chan = RabbitMQ.with_conn fn conn ->
      {:ok, chan} = Channel.open(conn)
      Basic.qos(chan, prefetch_count: @log_streamer_limit)
      {:ok, %{queue: queue}} = Queue.declare(chan, @queue, durable: true)
      Exchange.topic(chan, @exchange)
      Queue.bind(chan, @queue, @exchange, routing_key: "#")

      {:ok, _consumer_tag} = Basic.consume(chan, queue)
      {:ok, %{chan: chan, queue: queue}}
    end

    case open_chan do
      {:ok, state = %{chan: %{pid: pid}}} ->
        Process.monitor(pid)
        {:ok, state}
      {:error, :disconnected} ->
        {:stop, :disconnected}
    end
  end

  def handle_info({:basic_consume_ok, _}, state) do
    Logger.info("#{__MODULE__} connected to RabbitMQ.")
    {:noreply, state}
  end
  def handle_info({:basic_deliver, raw_payload,
                   %{delivery_tag: tag, routing_key: _routing_key}},
                  state = %{chan: chan, queue: _queue})
  do
    Task.start fn ->
      try do
        payload = %LogOutput{} = :erlang.binary_to_term(raw_payload)
        LogProcessor.process(payload)
      after
        Basic.ack(chan, tag)
      end
    end

    {:noreply, state}
  end
  # Channel died.
  def handle_info({:DOWN, _ref, :process, _pid, reason}, state) do
    Logger.warn("RabbitMQ Channel died! #{inspect reason}")
    shut_down(state)
  end
  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}
  def handle_info(_msg, state), do: {:noreply, state}

  defp shut_down(state) do
    Logger.debug("Log streamer going down... #{inspect state}")
    {:stop, :normal, state}
  end

  def terminate(_reason, %{chan: chan}) do
    try do
      Channel.close(chan)
    catch
      _, _ -> :ok
    end
  end
end
