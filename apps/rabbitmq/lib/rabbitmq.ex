defmodule RabbitMQ do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(RabbitMQ.PoolSup, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RabbitMQ.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def with_conn(fun) when is_function(fun, 1) do
    RabbitMQ.PoolSup.with_conn(fun)
  end

  def publish(exchange, routing_key, payload, options \\ []) do
    RabbitMQ.PoolSup.publish(exchange, routing_key, payload, options)
  end
end
