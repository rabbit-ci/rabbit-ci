defmodule RabbitCICore.Log do
  use RabbitCICore.Web, :model

  schema "logs" do
    field :stdio, :string

    belongs_to :script, RabbitCICore.Script

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    cast(model, params, ~w(stdio script_id), ~w())
  end
end
