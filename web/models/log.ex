defmodule Rabbitci.Log do
  use Ecto.Model

  schema "logs" do
    field :stdio, :string
    timestamps
  end
end
