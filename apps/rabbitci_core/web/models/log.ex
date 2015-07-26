defmodule RabbitCICore.Log do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Script

  schema "logs" do
    field :stdio, :string

    belongs_to :script, Script

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
