defmodule RabbitCICore.LogSaver do
  use GenServer
  use AMQP
  require Logger
  alias RabbitCICore.Log
  alias RabbitCICore.Repo
  alias RabbitCICore.Script

  @exchange "rabbitci_builds_processed_logs"

  # Client API
  def start_link do
    Logger.debug("Starting up LogSaver...")
    GenServer.start_link(__MODULE__, :ok)
  end

  # Server callbacks
  def init(:ok) do
    Process.flag(:trap_exit, true)

    open_chan = RabbitMQ.with_conn fn conn ->
      {:ok, chan} = Channel.open(conn)

      Basic.qos(chan, prefetch_count: 5) # TODO: Config this per node.

      {:ok, %{queue: queue}} = Queue.declare(chan, "", auto_delete: true)
      Exchange.topic(chan, @exchange)
      Queue.bind(chan, "", @exchange, routing_key: "#")

      {:ok, _consumer_tag} = Basic.consume(chan, queue)
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
    Logger.info("BuildMan.LogSaver started on #{hostname}")
    {:noreply, state}
  end

  def handle_info({:basic_cancel, _}, state), do: {:stop, :normal, state}
  def handle_info({:basic_cancel_ok, _}, state), do: {:noreply, state}

  def handle_info({:basic_deliver, payload,
                   %{delivery_tag: tag, routing_key: ident}},
                  chan) do
    Task.start_link fn ->
      try do
        update_log(payload, tag, ident, chan)
      after
        Basic.ack(chan, tag)
      end
    end

    {:noreply, chan}
  end

  def handle_info({:EXIT, _pid, _reason}, chan), do: {:noreply, chan}

  def update_log(payload, tag, ident, chan) do
    %{text: text, order: order} = :erlang.binary_to_term(payload)
    [_, build_id, script_name] = get_id(ident)
    script = Repo.get_by(Script, name: script_name, build_id: build_id)
    # TODO: Script ID should *not* be hardcoded
    %Log{stdio: text, script_id: script.id, order: order}
    |> Repo.insert
  end

  def terminate(_reason, chan) do
    try do
      Channel.close(chan)
    catch
      _, _ -> :ok
    end
  end

  defp get_id(ident), do: String.split(ident, ".")
end
