defmodule RabbitCICore.Script do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Log

  schema "scripts" do
    field :status, :string
    field :name, :string
    has_one :log, Log
    # TODO: artifacts
    belongs_to :build, Log
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    cast(model, params, ~w(build_id name status), ~w())
    # |> validate_inclusion(:status, []) # Need to validate status
  end
end
