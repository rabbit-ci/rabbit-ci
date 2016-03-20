defmodule RabbitCICore.Repo.Migrations.AddWebhookSecretToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :webhook_secret, :string
    end
  end
end
