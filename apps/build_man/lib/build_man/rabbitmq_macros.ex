defmodule BuildMan.RabbitMQMacros do
  @callback rabbitmq_connect(opts :: any) :: %{chan: %AMQP.Channel{}}

  defmacro __using__(_opts) do
    quote location: :keep do
      require Logger
      alias AMQP.Channel
      @behaviour GenServer
      @behaviour BuildMan.RabbitMQMacros

      def init(opts) do
        case rabbitmq_connect(opts) do
          {:ok, :disabled} -> {:ok, :disabled}
          {:ok, state = %{chan: %{pid: pid}}} ->
            Process.monitor(pid)
            {:ok, state}
          {:error, _} ->
            Logger.warn("Unable to connect in #{__MODULE__}. Retrying in 3000ms")
            :timer.sleep(3_000)
            {:stop, {:shutdown, :disconnected}}
        end
      end

      # Channel died.
      def handle_info({:DOWN, _ref, :process, pid, reason}, state = %{chan: %{pid: chan_pid}})
      when pid == chan_pid do
        Logger.warn("RabbitMQ Channel died. Stopping. #{inspect reason}")
        {:stop, {:shutdown, :channel_died}, state}
      end

      def terminate(_reason, %{chan: chan}) do
        Logger.debug("Terminate called in #{__MODULE__}")
        try do
          Channel.close(chan)
        catch
          _, _ -> :ok
        end
      end
    end
  end
end
