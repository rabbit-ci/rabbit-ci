defmodule RabbitCICore.EctoRepo.Migrations.StartAndFinishTime do
  use Ecto.Migration

  def change do
    alter table(:builds) do
      remove :start_time
      remove :finish_time
    end

    alter table(:steps) do
      add :start_time, :datetime
      add :finish_time, :datetime
    end
  end
end
