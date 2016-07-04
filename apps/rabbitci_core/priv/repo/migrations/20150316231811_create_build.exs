defmodule RabbitCICore.Repo.Migrations.CreateBuild do
  use Ecto.Migration

  def change do
    create table(:builds) do
      add :build_number, :integer
      add :branch_id, :integer
      add :start_time, :datetime
      add :finish_time, :datetime

      timestamps
    end
  end
end
