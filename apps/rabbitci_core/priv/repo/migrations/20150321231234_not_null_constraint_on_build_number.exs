defmodule RabbitCICore.Repo.Migrations.NotNullConstraintOnBuildNumber do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE builds ALTER COLUMN build_number SET NOT NULL")
  end

  def down do
    execute("ALTER TABLE builds ALTER COLUMN build_number DROP NOT NULL")
  end
end
