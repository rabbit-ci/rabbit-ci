defmodule RabbitCICore.Repo.Migrations.AddUniqueIndexToBranchNames do
  use Ecto.Migration

  def change do
    create unique_index(:branches, [:name, :project_id])
  end
end
