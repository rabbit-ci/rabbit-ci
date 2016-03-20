defmodule RabbitCICore.Repo.Migrations.AddOrderFieldToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :order, :integer
    end
  end
end
