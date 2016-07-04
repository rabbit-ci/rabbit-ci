defmodule RabbitCICore.Repo.Migrations.ChangeSshKeyToText do
  use Ecto.Migration

  def change do
    alter table(:ssh_keys) do
      modify :private_key, :text
    end
  end
end
