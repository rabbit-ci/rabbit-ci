defmodule RabbitCICore.EctoRepo.Migrations.ChangeLogStepIdToReference do
  use Ecto.Migration

  def change do
    alter table(:logs) do
      modify :step_id, references(:steps)
    end

    create index(:logs, [:step_id])
  end
end
