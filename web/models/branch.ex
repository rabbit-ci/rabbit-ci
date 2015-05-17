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
    |> validate_unique_with_scope(:name, [scope: :project_id])
  end

  def latest(record) do
    query = from(b in Build,
                 where: b.branch_id == ^record.id,
                 order_by: [desc: b.inserted_at],
                 limit: 1)
    Repo.one(query)
  end

  # def latest_success(record) do
  #   query = from(b in Build,
  #                where: b.branch_id == ^record.id and status,
  #                order_by: [desc: b.created_at],
  #                limit: 1)
  #   Repo.one(query)
  # end

end
