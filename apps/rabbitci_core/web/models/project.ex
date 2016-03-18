defmodule RabbitCICore.Project do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Repo
  alias RabbitCICore.Branch
  alias RabbitCICore.Build
  alias RabbitCICore.SSHKey

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
    model
    |> cast(params, ~w(name repo), ~w(webhook_secret))
    |> validate_format(:name, ~r/^[^\/]+\/[^\/]+$/)
    |> unique_constraint(:name)
    |> unique_constraint(:repo)
  end

  def latest_build(project) do
    query = from b in Build,
           join: br in assoc(b, :branch),
           join: p in assoc(br, :project),
          where: p.id == ^project.id,
       order_by: [desc: b.inserted_at],
          limit: 1,
        preload: [branch: br]

   Repo.one(query)
  end
end
