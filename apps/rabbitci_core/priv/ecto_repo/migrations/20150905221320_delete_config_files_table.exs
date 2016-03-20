defmodule RabbitCICore.Repo.Migrations.DeleteConfigFilesTable do
  use Ecto.Migration

  def change do
    drop table(:config_files)
  end
end
