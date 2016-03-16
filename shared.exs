defmodule Shared do
  def deps do
    [{:coverex, "~> 1.4", only: :test},
     {:credo, "~> 0.2.5", only: [:test, :dev]}]
  end
end
