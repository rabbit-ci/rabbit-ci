defmodule Rabbitci.Repo.Migrations.CreateConfigModel do
  use Ecto.Migration

  def change do
    create table(:configs) do
      add :build_id, :integer
      add :body, :text

      timestamps
    end
  end
end
