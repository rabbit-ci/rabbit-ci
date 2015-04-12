defmodule Rabbitci.ConfigFile do
  use Rabbitci.Web, :model

  schema "config_files" do
    field :raw_body, :string

    belongs_to :build, Rabbitci.Build

    timestamps
  end

  @required_fields ~w(raw_body build_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
