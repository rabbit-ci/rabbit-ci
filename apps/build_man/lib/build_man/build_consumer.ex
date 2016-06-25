defmodule BuildMan.BuildConsumer do
  use AMQP
  use GenServer
  use BuildMan.RabbitMQMacros
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @exchange Application.get_env(:build_man, :build_exchange)
  @queue Application.get_env(:build_man, :build_queue)
  @worker_limit Application.get_env(:build_man, :worker_limit)

  def rabbitmq_connect(_opts) do
    case @worker_limit do
      0 -> {:ok, :disabled}
      _ ->
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
  end

  # AMQP Stuff
  def handle_info({:basic_consume_ok, _}, state) do
    Logger.info("#{__MODULE__} connected to RabbitMQ.")
    {:noreply, state}
  end

  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}

  def handle_info({:basic_deliver, payload,
                   %{delivery_tag: tag, routing_key: _routing_key}}, %{chan: chan}) do
    Logger.debug("Starting build...")

    config = :erlang.binary_to_term(payload)
    {:ok, _pid} = Supervisor.start_child(BuildMan.WorkerSup, [[config, {chan, tag}]])

    {:noreply, chan}
  end
end
