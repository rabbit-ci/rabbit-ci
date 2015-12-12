defmodule RabbitCICore.Repo.Migrations.AddUniqueIndexToProjectRepo do
  use Ecto.Migration

  def change do
    create unique_index(:projects, [:repo])
  end
end
