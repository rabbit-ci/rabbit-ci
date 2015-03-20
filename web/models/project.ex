defmodule Rabbitci.Project do
  use Ecto.Model

  schema "projects" do
    field :name, :string
    field :repo, :string

    has_many :branches, Rabbitci.Branch

    timestamps
  end

  def branch_ids(record) do
    from(b in Rabbitci.Branch,
         where: b.project_id == ^record.id,
         select: b.id)
    |> Rabbitci.Repo.all
  end

end
