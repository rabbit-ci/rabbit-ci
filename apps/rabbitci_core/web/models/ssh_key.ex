defmodule RabbitCICore.SSHKey do
  use RabbitCICore.Web, :model
  alias RabbitCICore.Build
  alias RabbitCICore.Repo

  schema "ssh_keys" do
    field :private_key, :string
    belongs_to :project, RabbitCICore.Project

    timestamps
  end

  @required_fields ~w(private_key project_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:project_id)
  end

  def private_key_from_build_id(build_id) do
    query = from b in Build,
          where: b.id == ^build_id,
           join: br in assoc(b, :branch),
           join: p in assoc(br, :project),
           join: ssh in assoc(p, :ssh_key),
         select: ssh.private_key

    Repo.one(query)
  end
end
