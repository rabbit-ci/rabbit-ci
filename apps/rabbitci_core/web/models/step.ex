defmodule RabbitCICore.Step do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Log

  schema "steps" do
    field :status, :string
    field :name, :string
    has_many :logs, Log
    # TODO: artifacts
    belongs_to :build, Log
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    cast(model, params, ~w(build_id name status), ~w())
    |> validate_inclusion(:status, ["queued", "running", "failed", "finished"])
  end
end
