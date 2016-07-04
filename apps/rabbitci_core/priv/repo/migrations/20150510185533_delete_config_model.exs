defmodule RabbitCICore.Repo.Migrations.DeleteConfigModel do
  use Ecto.Migration

  def change do
    drop table(:configs)
  end
end
