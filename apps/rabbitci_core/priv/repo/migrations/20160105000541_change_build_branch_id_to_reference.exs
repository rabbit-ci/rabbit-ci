defmodule RabbitCICore.Repo.Migrations.ChangeBuildBranchIdToReference do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      modify :branch_id, references(:branches)
    end
  end
end
