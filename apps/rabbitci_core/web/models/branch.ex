defmodule RabbitCICore.Branch do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Build
  alias RabbitCICore.Repo
  alias RabbitCICore.Project
  alias RabbitCICore.Branch

  schema "branches" do
    field :name, :string
    has_many :builds, Build
    belongs_to :project, Project
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(name project_id), ~w())
    |> unique_constraint(:name, name: :branches_name_project_id_index)
    |> foreign_key_constraint(:project_id)
  end

  def latest_build(branch = %Branch{}) do
    query = from b in assoc(branch, :builds),
          limit: 1,
       order_by: [desc: b.build_number],
        preload: :branch

    Repo.one(query)
  end
end
