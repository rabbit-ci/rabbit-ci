defmodule BuildMan.LogStreamer do
  @moduledoc """
  A GenServer for dealing with logs from Builds.
  """

  require Logger
  use AMQP
  use GenServer
  use BuildMan.RabbitMQMacros
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

  def log_string(str, type, order, job_id, colors) do
    RabbitMQ.publish(@exchange, "#{type}.#{job_id}",
                     :erlang.term_to_binary(%LogOutput{text: str,
                                                       order: order,
                                                       job_id: job_id,
                                                       type: to_string(type),
                                                       colors: colors}))
  end

  # Server callbacks
  def rabbitmq_connect(_opts) do
    RabbitMQ.with_conn fn conn ->
      {:ok, chan} = Channel.open(conn)
      Basic.qos(chan, prefetch_count: @log_streamer_limit)
      {:ok, %{queue: queue}} = Queue.declare(chan, @queue, durable: true)
      Exchange.topic(chan, @exchange)
      Queue.bind(chan, @queue, @exchange, routing_key: "#")

      {:ok, _consumer_tag} = Basic.consume(chan, queue)
      {:ok, %{chan: chan, queue: queue}}
    end
  end

  def handle_info({:basic_deliver, raw_payload, %{delivery_tag: tag}},
                  state = %{chan: chan}) do
    try do
      payload = %LogOutput{} = :erlang.binary_to_term(raw_payload)
      LogProcessor.process(payload)
    after
      Basic.ack(chan, tag)
    end

    {:noreply, state}
  end

  def handle_info({:basic_consume_ok, _}, state), do: {:noreply, state}
  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}
  def handle_info(_msg, state), do: {:noreply, state}
end
