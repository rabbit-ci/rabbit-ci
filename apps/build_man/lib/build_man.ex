defmodule BuildMan do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # RabbitMQ must be first so that the pool can be created before other
      # GenServers attempt to use it.
      supervisor(BuildMan.RabbitMQ, []),

      supervisor(BuildMan.BuildSup, []),
    ]

    opts = [strategy: :one_for_one, name: BuildMan.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
