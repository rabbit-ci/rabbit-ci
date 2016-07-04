defmodule RabbitCICore.Repo.Migrations.RenameStepsToJobs do
  use Ecto.Migration

  def change do
    # Remove the constraint. The new Step will have this constraint.
    ~s(ALTER TABLE "public"."steps" DROP CONSTRAINT "steps_build_id_fkey";)
    |> execute

    rename table(:steps), to: table(:jobs)
    drop index(:logs, [:step_id])
    rename table(:logs), :step_id, to: :job_id

    ~s(ALTER TABLE "public"."logs" RENAME CONSTRAINT "logs_step_id_fkey" TO "logs_job_id_fkey";)
    |> execute
  end
end
