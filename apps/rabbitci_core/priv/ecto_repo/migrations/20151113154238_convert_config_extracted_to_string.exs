defmodule RabbitCICore.Repo.Migrations.ConvertConfigExtractedToString do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      modify :config_extracted, :string
    end
  end
end
