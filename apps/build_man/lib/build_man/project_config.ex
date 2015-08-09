defmodule BuildMan.ProjectConfig do
  @moduledoc """
  GenServer for processing project configs.
  """

  use GenServer
  use AMQP

  @exchange "rabbitci_builds_build_exchange"
  @queue "rabbitci_builds_build_queue"

  # Client API
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: ProjectConfigSup)
  end

  @doc """
  Queue build from parsed config. See `parse_from_yaml/1` for parsing
  the config.
  """
  def queue_build(config) do
    GenServer.cast(ProjectConfigSup, {:queue_build, config})
  end

  def parse_from_yaml(content) do
    :yamerl_constr.string(content)
  end

  # Server callbacks
  def init(:ok) do
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)

    Queue.declare(chan, @queue, durable: true)
    Exchange.fanout(chan, @exchange, durable: true)
    Queue.bind(chan, @queue, @exchange)

    {:ok, chan}
  end

  def handle_cast({:queue_build, config}, chan) do
    AMQP.Basic.publish chan, @exchange, "", :erlang.term_to_binary(config)
    {:noreply, chan}
  end

  def queue_builds(%{"steps" => steps, "repo" => repo}) when is_list(steps) do
    for step <- steps do
      for box <- step["boxes"] do
        %{
          box: box,
          script: step["command"],
          name: step["name"],
          repo: repo
        } |> queue_build
      end
    end
  end
end
