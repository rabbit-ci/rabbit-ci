defmodule RabbitCICore.Repo.Migrations.AddTypeToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :type, :string
    end
  end
end
