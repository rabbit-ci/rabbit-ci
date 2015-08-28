defmodule BuildMan.ProjectConfig do
  alias RabbitCICore.Repo
  alias RabbitCICore.Script
  alias RabbitCICore.Build
  alias BuildMan.GitHelpers

  @moduledoc """
  Module for processing configs.
  """

  @exchange "rabbitci_builds_build_exchange"

  @doc """
  Queue build from parsed config. See `parse_from_yaml/1` for parsing
  the config.
  """
  def queue_build(config, build_id, step_name) do
    Repo.get(Build, build_id)
    |> Ecto.Model.build(:scripts, %{status: "queued", name: step_name})
    |> Repo.insert!

    RabbitMQ.publish(@exchange, "#{build_id}.#{step_name}",
                     :erlang.term_to_binary(config))
  end

  def parse_from_yaml(content) do
    YamlElixir.read_from_string(content)
  end

  def queue_builds(%{"steps" => steps, "repo" => repo}, build_id, payload)
  when is_list(steps) do
    git_cmd =
      GitHelpers.clone_repo("workdir", payload, false)
    |> Enum.join("\n")

    for step <- steps do
      for box <- step["boxes"] do
        %{
          box: box,
          script: step["command"],
          name: step["name"],
          repo: repo,
          git_cmd: git_cmd
        } |> queue_build(build_id, step["name"] <> box)
      end
    end
  end
end
