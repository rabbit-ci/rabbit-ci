Code.require_file "../../shared.exs", __DIR__

defmodule RabbitCICore.Mixfile do
  use Mix.Project

  def project do
    [app: :rabbitci_core,
     version: "0.0.1",
     elixir: "~> 1.0",
     elixirc_paths: elixirc_paths(Mix.env),
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     compilers: [:phoenix] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
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
    [{:phoenix, "~> 1.0.0"},
     {:phoenix_ecto, "~> 1.1.0"},
     {:postgrex, "~> 0.9.1"},
     {:cowboy, "~> 1.0"},
     {:rabbitmq, in_umbrella: true},
     {:ecto, "~> 1.0.0"},
     {:ja_serializer, github: "AgilionApps/ja_serializers"}]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]
end
