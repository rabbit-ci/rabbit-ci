defmodule RabbitCICore.Repo.Migrations.AddConfigExtractedToBuilds do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      add :config_extracted, :boolean
    end
  end
end
