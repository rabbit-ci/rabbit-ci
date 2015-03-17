defmodule Rabbitci.Repo.Migrations.AddIndexes do
  use Ecto.Migration

  def change do
    create index(:branches, [:project_id])
    create index(:builds,   [:branch_id])
    create index(:scripts,  [:build_id])
    create index(:logs,     [:script_id])
  end
end
