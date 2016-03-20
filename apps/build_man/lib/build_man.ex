defmodule BuildMan do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(BuildMan.WorkerSup, []),
      worker(BuildMan.BuildConsumer, []),
      worker(BuildMan.ConfigExtractionSup, []),
      worker(BuildMan.LogStreamer, [])
    ]

    opts = [strategy: :one_for_one, name: BuildMan.Supervisor,
            max_restarts: 10_000]
    Supervisor.start_link(children, opts)
  end
end
