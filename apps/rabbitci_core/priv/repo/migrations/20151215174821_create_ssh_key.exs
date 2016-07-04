defmodule RabbitCICore.Repo.Migrations.CreateSSHKey do
  use Ecto.Migration

  def change do
    create table(:ssh_keys) do
      add :private_key, :string
      add :project_id, references(:projects)

      timestamps
    end
    create index(:ssh_keys, [:project_id])

  end
end
