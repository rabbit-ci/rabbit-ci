defmodule BuildMan.Mixfile do
  use Mix.Project

  def project do
    [app: :build_man,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     test_coverage: [tool: ExCoveralls],
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :amqp, :exec, :yamerl],
     mod: {BuildMan, []}]
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
    [{:excoveralls, "~> 0.3.0", only: [:dev, :test]},
     {:amqp, "0.1.1"},
     {:mock, "0.1.1", only: :test},
     {:yamerl, github: "yakaz/yamerl"},
     {:exec, github: "saleyn/erlexec"}]
  end
end
