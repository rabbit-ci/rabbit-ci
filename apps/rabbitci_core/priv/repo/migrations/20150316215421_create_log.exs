defmodule RabbitCICore.Repo.Migrations.CreateLog do
  use Ecto.Migration

  def change do
    create table(:log) do
      add :stdio, :text

      timestamps
    end
  end
end
