defmodule BuildMan.ProjectConfig do
  alias RabbitCICore.Repo
  alias RabbitCICore.Build
  alias BuildMan.GitHelpers

  @moduledoc """
  Module for processing configs.
  """

  @exchange Application.get_env(:build_man, :build_exchange)

  @doc """
  Queue build from parsed config. See `parse_from_yaml/1` for parsing
  the config.
  """
  def queue_build(config, build_id, step_name) do
    step =
      Repo.get(Build, build_id)
      |> Ecto.Model.build(:steps, %{status: "queued", name: step_name})
      |> Repo.insert!

    config = Map.merge(config, %{build_id: build_id, step_name: step_name,
                                 step_id: step.id})

    RabbitMQ.publish(@exchange, "#{build_id}.#{step_name}",
                     :erlang.term_to_binary(config))
  end

  def parse_from_yaml(content) do
    YamlElixir.read_from_string(content)
  end

  def queue_builds(%{"steps" => steps, "repo" => repo_url}, build_id, repo)
  when is_list(steps) do
    git_cmd =
      GitHelpers.clone_repo("workdir", repo, false)
      |> Enum.join("\n")

    for step <- steps do
      for box <- step["boxes"] do
        %{
          box: box,
          script: step["command"],
          name: step["name"],
          repo: repo_url,
          git_cmd: git_cmd
        } |> queue_build(build_id, "#{step["name"]} #{box}")
      end
    end
  end
end
