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
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [mod: {RabbitCICore, []},
     applications: [:phoenix, :cowboy, :logger, :ecto, :postgrex, :exq,
                    :phoenix_ecto]]
  end

  # Specifies your project dependencies
  #
  # Type `mix help deps` for examples and options
  defp deps do
    [{:phoenix, "~> 0.14.0"},
     {:phoenix_ecto, "~> 0.5.0"},
     {:postgrex, "~> 0.8.0"},
     {:cowboy, "~> 1.0"},
     {:postgrex, "~> 0.8.0"},
     {:ecto, "~> 0.13.0"},
     {:ashes, ">= 0.0.3"},
     {:mock, "~> 0.1.1"},
     {:exq, github: "akira/exq"},
     {:ja_serializer, github: "AgilionApps/ja_serializers"},
     {:excoveralls, "~> 0.3.0", only: [:dev, :test]},
     {:eredis, github: 'wooga/eredis', tag: 'v1.0.5'}
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]
end
