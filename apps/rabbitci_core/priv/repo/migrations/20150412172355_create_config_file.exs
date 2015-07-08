defmodule RabbitCICore.Repo.Migrations.CreateConfigFile do
  use Ecto.Migration

  def change do
    create table(:config_files) do
      add :raw_body, :text
      add :build_id, :integer

      timestamps
    end
  end
end
