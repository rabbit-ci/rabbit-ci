defmodule RabbitCICore.Repo.Migrations.DropProjectNameRepoUniqueIndex do
  use Ecto.Migration

  def change do
    drop index(:projects, [:name, :repo])
  end
end
