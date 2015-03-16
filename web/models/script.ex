defmodule Rabbitci.Script do
  use Rabbitci.Web, :model

  schema "scripts" do
    field :status, :string
    has_one :log, Rabbitci.Log
    # TODO: artifacts
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    cast(model, params, ~w(status), ~w())
  end
end
