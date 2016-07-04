defmodule RabbitCICore.Repo.Migrations.AddBuildNumberUniqueConstraintToBuilds do
  use Ecto.Migration

  def change do
    create unique_index(:builds, [:branch_id, :build_number])
  end
end
