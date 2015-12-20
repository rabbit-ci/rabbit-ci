defmodule RabbitCICore.Project do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Repo
  alias RabbitCICore.Branch
  alias RabbitCICore.Build
  alias RabbitCICore.SSHKey
  alias RabbitCICore.Project

  schema "projects" do
    field :name, :string
    field :repo, :string
    field :webhook_secret, :string

    has_many :branches, Branch
    has_one :ssh_key, SSHKey

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    cast(model, params, ~w(name repo), ~w())
    |> unique_constraint(:name)
    |> unique_constraint(:repo)
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
