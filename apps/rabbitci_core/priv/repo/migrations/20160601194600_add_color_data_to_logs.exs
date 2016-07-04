defmodule RabbitCICore.Repo.Migrations.AddColorDataToLogs do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      add :fg, :string
      add :bg, :string
      add :style, :string
    end
  end
end
