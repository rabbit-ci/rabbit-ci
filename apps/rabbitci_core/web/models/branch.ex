defmodule RabbitCICore.Branch do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Build
  alias RabbitCICore.Repo
  alias RabbitCICore.Project
  alias RabbitCICore.Branch

  schema "branches" do
    field :name, :string
    field :exists_in_git, :boolean

    has_many :builds, Build

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

  def latest_build(branch = %Branch{}) do
    query = (from b in Build,
             where: b.branch_id == ^branch.id,
             limit: 1,
             order_by: [desc: b.build_number])

    Repo.one(query)
  end
end
