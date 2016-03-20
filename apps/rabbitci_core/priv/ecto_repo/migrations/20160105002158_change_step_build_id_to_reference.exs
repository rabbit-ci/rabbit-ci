defmodule RabbitCICore.EctoRepo.Migrations.ChangeStepBuildIdToReference do
  use Ecto.Migration

  def change do
    alter table(:steps) do
      modify :build_id, references(:builds)
    end

    create index(:steps, [:build_id])
  end
end
