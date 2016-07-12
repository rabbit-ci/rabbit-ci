Code.require_file "../../shared.exs", __DIR__

defmodule RabbitCICore.Mixfile do
  use Mix.Project

  def project do
    [app: :rabbitci_core,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     test_coverage: [tool: Coverex.Task],
     aliases: aliases(),
     deps: Shared.deps ++ deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {RabbitCICore, []},
     applications: [:phoenix, :cowboy, :logger, :ecto, :postgrex,
                    :phoenix_ecto, :rabbitmq]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 1.2.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:cowboy, "~> 1.0"},
     {:rabbitmq, in_umbrella: true},
     {:ecto, github: "elixir-ecto/ecto", override: true},
     # Important fix in Ecto master branch. Remove this and replace with below
     # code when next ecto version is released.
     #
     # {:ecto, "~> 2.0"},
     {:ex_machina, only: :test, github: "thoughtbot/ex_machina"},
     {:ja_serializer, github: "AgilionApps/ja_serializers"},
     {:corsica, "~> 0.5"}]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
