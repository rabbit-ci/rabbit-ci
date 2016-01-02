defmodule RabbitCICore.Repo.Migrations.RemoveExistsInGitFromBranches do
  use Ecto.Migration

  def change do
    alter table(:branches) do
      remove :exists_in_git
    end
  end
end
