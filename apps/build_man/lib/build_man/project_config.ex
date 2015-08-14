defmodule BuildMan.ProjectConfig do
  @moduledoc """
  Module for processing configs.
  """

  @exchange "rabbitci_builds_build_exchange"

  @doc """
  Queue build from parsed config. See `parse_from_yaml/1` for parsing
  the config.
  """
  def queue_build(config) do
    BuildMan.RabbitMQ.publish(@exchange, "", :erlang.term_to_binary(config))
  end

  def parse_from_yaml(content) do
    :yamerl_constr.string(content)
  end

  def queue_builds(%{"steps" => steps, "repo" => repo}) when is_list(steps) do
    for step <- steps do
      for box <- step["boxes"] do
        %{
          box: box,
          script: step["command"],
          name: step["name"],
          repo: repo
        } |> queue_build
      end
    end
  end
end
