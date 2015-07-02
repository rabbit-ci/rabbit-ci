defmodule RabbitCICore.Repo.Migrations.AddScriptIdToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :script_id, :integer
    end
  end
end
