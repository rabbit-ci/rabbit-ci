defmodule Rabbitci.Project do
  use Rabbitci.Web, :model

  alias Rabbitci.Repo
  alias Rabbitci.Branch
  alias Rabbitci.Build

  schema "projects" do
    field :name, :string
    field :repo, :string

    has_many :branches, Rabbitci.Branch

    timestamps
  end

  def changeset(model, params \\ nil) do
    cast(model, params, ~w(name repo), ~w())
  end

  def latest_build(project) do
    branch_ids = Repo.all(from b in Branch,
                           where: b.project_id == ^project.id,
                           select: b.id)
    build = Repo.one(from b in Build,
                     where: b.branch_id in ^branch_ids,
                     order_by: [desc: b.inserted_at],
                     limit: 1)
    if build != nil do
      Repo.preload(build, :branch)
    else
      nil
    end
  end


end
