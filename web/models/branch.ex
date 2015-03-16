defmodule Rabbitci.Branch do
  use Ecto.Model

  schema "branches" do
    field :name, :string
    field :exists_in_git, :boolean

    has_many :builds, Rabbitci.Build

    # belongs_to :project, Project
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    cast(model, params, ~w(name, exists_in_git), ~w())
  end
end
