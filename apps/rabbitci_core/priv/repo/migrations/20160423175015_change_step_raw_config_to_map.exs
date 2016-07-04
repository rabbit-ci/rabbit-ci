defmodule RabbitCICore.Repo.Migrations.ChangeStepRawConfigToMap do
  use Ecto.Migration

  def change do
    alter table(:steps) do
      remove :raw_config
      add :raw_config, :map
    end
  end
end
