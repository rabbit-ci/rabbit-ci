defmodule RabbitCICore.Project do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Repo
  alias RabbitCICore.Branch
  alias RabbitCICore.Build
  alias RabbitCICore.Project

  schema "projects" do
    field :name, :string
    field :repo, :string

    has_many :branches, Branch

    timestamps
  end

  def changeset(model, params \\ nil) do
    cast(model, params, ~w(name repo), ~w())
    |> unique_constraint(:name)
  end

  def latest_build(project) do
   (from b in Build,
    join:     g in Branch,
    on:       b.branch_id == g.id,
    join:     p in Project,
    on:       g.project_id == ^project.id,
    order_by: [desc: b.inserted_at],
    limit:    1,
    preload:  [branch: g]) |> Repo.one
  end
end
