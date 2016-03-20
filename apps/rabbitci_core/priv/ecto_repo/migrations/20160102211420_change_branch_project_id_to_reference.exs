defmodule RabbitCICore.EctoRepo.Migrations.ChangeBranchProjectIdToReference do
  use Ecto.Migration

  def change do
    alter table(:branches) do
      modify :project_id, references(:projects)
    end
  end
end
