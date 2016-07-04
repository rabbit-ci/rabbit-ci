defmodule RabbitCICore.Repo.Migrations.RenameLogToLogs do
  use Ecto.Migration

  def up do
    execute("ALTER TABLE log RENAME TO logs")
  end

  def down do
    execute("ALTER TABLE logs RENAME TO log")
  end

end
