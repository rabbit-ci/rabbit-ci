defmodule Rabbitci.ProjectSerializer do
  use Remodel

  @array_root :projects

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :name, :repo, :inserted_at,
              :updated_at, :links, :latest_branch, :branches]


  def links(record, %{conn: conn}) do
    %{branches: Rabbitci.Router.Helpers.branch_path(conn, :index, record.name)}
  end

  def branches(record) do
    build = Rabbitci.Project.latest_build(record)
    if build == nil do
      []
    else
      case [build.branch.name] do
        [nil] -> []
        a = _ -> a
      end
    end
  end

  def latest_branch(record) do
    case Rabbitci.Project.latest_build(record) do
      nil -> nil
      latest ->
        if latest.branch != nil do
          latest.branch.name
        else
          nil
        end
    end
  end

  def id(record), do: record.name

  SerializerHelpers.time(inserted_at, Rabbitci.Project)
  SerializerHelpers.time(updated_at, Rabbitci.Project)
end
