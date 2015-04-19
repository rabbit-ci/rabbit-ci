defmodule Rabbitci.Repo.Migrations.AddNameToScripts do
  use Ecto.Migration

  def change do
    alter table(:scripts) do
      add :name, :string
    end
  end
end
