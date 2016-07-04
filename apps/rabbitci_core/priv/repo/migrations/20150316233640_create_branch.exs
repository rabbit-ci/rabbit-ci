defmodule RabbitCICore.Repo.Migrations.CreateBranch do
  use Ecto.Migration

  def change do
    create table(:branches) do
      add :name, :string
      add :exists_in_git, :boolean
      add :project_id, :integer

      timestamps
    end
  end
end
