defmodule Rabbitci.Log do
  use Ecto.Model

  schema "Logs" do
    field :stdio, :string
  end
end
