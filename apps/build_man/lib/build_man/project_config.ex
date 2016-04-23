defmodule BuildMan.ProjectConfig do
  alias RabbitCICore.Repo
  alias RabbitCICore.Build

  @moduledoc """
  Module for processing configs.
  """

  @exchange Application.get_env(:build_man, :build_exchange)

  def parse_from_json(content) do
    Poison.decode!(content)
  end

  @doc """
  Queue builds from parsed config. See `parse_from_yaml/1` for parsing
  the config.
  """
  def queue_builds(%{"jobs" => jobs}, build_id, pr_or_commit)
  when is_list(jobs) do
    build = Repo.get(Build, build_id)

    for job_config <- jobs do
      for box <- job_config["boxes"] do
        job =
          build
            |> Ecto.Model.build(:jobs, %{status: "queued", name: "#{job_config["name"]} #{box}"})
            |> Repo.insert!

        config = %{
          script: job_config["script"],
          before_script: job_config["before_script"],
          build_id: build.id,
          job_id: job.id,
          provider_config: %{git: Map.take(pr_or_commit, [:pr, :commit]),
                             box: box}
        }

        RabbitMQ.publish(@exchange, "#{build.id}.#{job.id}", :erlang.term_to_binary(config))
      end
    end
  end
end
