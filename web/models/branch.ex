defmodule Rabbitci.Branch do
  use Rabbitci.Web, :model
  alias Rabbitci.Build
  alias Rabbitci.Repo

  schema "branches" do
    field :name, :string
    field :exists_in_git, :boolean

    has_many :builds, Rabbitci.Build

    belongs_to :project, Project
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    cast(model, params, ~w(name exists_in_git project_id), ~w())
    |> validate_unique(:name, scope: [:project_id], on: Repo)
  end

  def latest_build(branch = %Rabbitci.Branch{}) do
    query = (from b in Rabbitci.Build,
             where: b.branch_id == ^branch.id,
             limit: 1,
             order_by: [desc: b.build_number])

    Rabbitci.Repo.one(query)
  end
end
