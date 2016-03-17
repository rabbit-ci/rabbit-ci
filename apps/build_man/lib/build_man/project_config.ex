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
  def queue_builds(%{"steps" => steps}, build_id, pr_or_commit)
  when is_list(steps) do
    build = Repo.get(Build, build_id)

    for step_config <- steps do
      for box <- step_config["boxes"] do
        step =
          build
            |> Ecto.Model.build(:steps, %{status: "queued", name: "#{step_config["name"]} #{box}"})
            |> Repo.insert!

        config = %{
          box: box,
          script: step_config["script"],
          before_script: step_config["before_script"],
          build_id: build.id,
          step_id: step.id,
          git: Map.take(pr_or_commit, [:pr, :commit])
        }

        RabbitMQ.publish(@exchange, "#{build.id}.#{step.id}", :erlang.term_to_binary(config))
      end
    end
  end
end
