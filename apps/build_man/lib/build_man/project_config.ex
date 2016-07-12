defmodule BuildMan.ProjectConfig do
  alias RabbitCICore.Repo
  alias RabbitCICore.RecordPubSubChannel, as: PubSub
  alias RabbitCICore.{Build, Step, Job}

  @moduledoc """
  Module for processing configs.
  """

  @exchange Application.get_env(:build_man, :build_exchange)

  def parse_from_json(content) do
    Poison.decode!(content)
  end

  @doc """
  Queue builds from parsed config.
  """
  def queue_builds(%{"steps" => steps}, build_id, pr_or_commit)
  when is_list(steps) do
    build = Repo.get(Build, build_id)

    for step_config <- steps do
      # Create step
      step_changes = %{script: step_config["script"],
                       before_script: step_config["before_script"],
                       name: step_config["name"],
                       raw_config: step_config}

      step =
        build
        |> Ecto.build_assoc(:steps)
        |> Step.changeset(step_changes)
        |> Repo.insert!

      PubSub.new_step step

      for box <- step_config["boxes"] do
        job =
          step
          |> Ecto.build_assoc(:jobs)
          |> Job.changeset(%{status: "queued", box: box, provider: step_config["provider"]})
          |> Repo.insert!

        PubSub.new_job job

        config = %{
          build_id: build.id,
          job_id: job.id,
          step_id: step.id,
          provider: job.provider,
          provider_config: %{git: Map.take(pr_or_commit, [:pr, :commit])}
        }

        RabbitMQ.publish(@exchange, "#{build.id}.#{job.id}", :erlang.term_to_binary(config))
      end
    end
  end
end
