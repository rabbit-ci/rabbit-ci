defmodule RabbitCICore.Repo.Migrations.CreateScript do
  use Ecto.Migration

  def change do
    create table(:scripts) do
      add :status, :string
      add :log_id, :integer
      timestamps
    end
  end
end
