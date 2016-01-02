defmodule RabbitCICore.Repo.Migrations.RenameScriptsToSteps do
  use Ecto.Migration

  def change do
    rename table(:scripts), to: table(:steps)
    rename table(:logs), :script_id, to: :step_id
  end
end
