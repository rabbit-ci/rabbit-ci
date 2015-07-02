defmodule RabbitCICore.Repo.Migrations.DeleteLogId do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      remove :log_id
    end
  end
end
