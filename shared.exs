defmodule Shared do
  def deps do
    [{:credo, "~> 0.9", only: [:test, :dev]}]
  end
end
