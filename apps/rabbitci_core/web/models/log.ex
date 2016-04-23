defmodule RabbitCICore.Log do
  use RabbitCICore.Web, :model
  alias RabbitCICore.Job

  schema "logs" do
    field :stdio, :string
    field :order, :integer
    field :type, :string

    belongs_to :job, Job

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(stdio job_id type order), ~w())
    |> validate_inclusion(:type, ["stdout", "stderr"])
    |> foreign_key_constraint(:job_id)
  end
end
