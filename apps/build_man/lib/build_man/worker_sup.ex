defmodule BuildMan.WorkerSup do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(BuildMan.Vagrant, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one, name: __MODULE__)
  end
end
