defmodule RabbitCICore.Repo.Migrations.CreateProject do
  use Ecto.Migration

  def change do
    create table(:projects) do
      add :name, :string
      add :repo, :string
    end
  end
end
