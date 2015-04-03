defmodule Rabbitci.Project do
  use Rabbitci.Web, :model

  schema "projects" do
    field :name, :string
    field :repo, :string

    has_many :branches, Rabbitci.Branch

    timestamps
  end

  def branch_names(record) do
    from(b in Rabbitci.Branch,
         where: b.project_id == ^record.id,
         select: b.name)
    |> Rabbitci.Repo.all
  end

end
