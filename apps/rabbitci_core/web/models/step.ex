defmodule RabbitCICore.Step do
  use RabbitCICore.Web, :model
  alias RabbitCICore.{Build, Job}

  schema "steps" do
    field :name, :string
    field :raw_config, :map
    field :script, :string
    field :before_script, :string
    belongs_to :build, Build
    has_many :jobs, Job
    timestamps
  end

  @required_fields ~w(name build_id)
  @optional_fields ~w(raw_config script before_script)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:build_id)
  end
end
