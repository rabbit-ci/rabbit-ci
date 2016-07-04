defmodule RabbitCICore.Repo.Migrations.CreateNewStepsAndModifyJobColumns do
  use Ecto.Migration

  def change do
    create table(:steps) do
      add :build_id, references(:builds)
      add :raw_config, :text
      add :script, :text
      add :before_script, :text
      add :name, :string

      timestamps
    end

    alter table(:jobs) do
      add :step_id, references(:steps)
      remove :build_id
      remove :name
      add :box, :string
      add :provider, :string
    end
  end
end
