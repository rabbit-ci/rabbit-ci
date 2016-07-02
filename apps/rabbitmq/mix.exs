Code.require_file "../../shared.exs", __DIR__

defmodule Rabbitmq.Mixfile do
  use Mix.Project

  def project do
    [app: :rabbitmq,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     test_coverage: [tool: Coverex.Task],
     deps: Shared.deps ++ deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :amqp],
     mod: {RabbitMQ, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:myapp, in_umbrella: true}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [{:amqp, "~> 0.1.4"},
     {:poolboy, "~> 1.5.0"},
     {:connection, "~> 1.0.3"}]
  end
end
