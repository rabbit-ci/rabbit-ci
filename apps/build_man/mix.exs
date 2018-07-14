Code.require_file("../../shared.exs", __DIR__)

defmodule BuildMan.Mixfile do
  use Mix.Project

  def project do
    [
      app: :build_man,
      version: "0.0.1",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      elixirc_paths: elixirc_paths(Mix.env()),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      aliases: aliases(),
      deps: Shared.deps() ++ deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :exec, :rabbitmq, :rabbitci_core], mod: {BuildMan, []}]
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
    [
      {:rabbitmq, in_umbrella: true},
      {:rabbitci_core, in_umbrella: true},
      {:exec, github: "saleyn/erlexec"},
      {:poison, "~> 2.0"},
      {:uuid, "~> 1.1.0"}
    ]
  end

  # Specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
