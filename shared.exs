defmodule Shared do
  def deps do
    [{:mock, "~> 0.1.1", only: [:test]},
     {:excoveralls, "~> 0.3.0", only: [:test, :dev]}]
  end
end
