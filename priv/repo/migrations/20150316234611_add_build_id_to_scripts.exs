defmodule Rabbitci.Repo.Migrations.AddBuildIdToScripts do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      add :build_id, :integer
    end
  end
end
