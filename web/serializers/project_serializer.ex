defmodule Rabbitci.ProjectSerializer do
  use Remodel

  @array_root :projects

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :name, :repo, :branch_ids, :branch_url, :inserted_at,
              :updated_at]

  # Conn is scope
  def branch_url(_, conn), do: Rabbitci.Router.Helpers.branch_path(conn, :index)
  def branch_ids(record), do: Rabbitci.Project.branch_ids(record)

  SerializerHelpers.time(inserted_at, Rabbitci.Project)
  SerializerHelpers.time(updated_at, Rabbitci.Project)
end
