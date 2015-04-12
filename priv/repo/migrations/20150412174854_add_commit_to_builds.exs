defmodule Rabbitci.Repo.Migrations.AddCommitToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :commit, :string
    end
  end
end
