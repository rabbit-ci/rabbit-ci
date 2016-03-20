defmodule RabbitCICore.Repo.Migrations.UniquenessConstraints do
  use Ecto.Migration

  def change do
    create index(:projects, [:name, :repo], unique: true)
  end
end
