defmodule Shared do
  def deps do
    [{:mock, "~> 0.1.1", only: [:test]},
     {:coverex, "~> 1.4", only: :test},
     {:credo, "~> 0.2.5", only: [:test, :dev]}]
  end
end
