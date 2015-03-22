defmodule Rabbitci.ProjectSerializer do
  use Remodel

  @array_root :projects

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :name, :repo, :branch_names, :branch_url, :inserted_at,
              :updated_at]

  # Conn is scope
  def branch_url(m, conn) do
    Rabbitci.Router.Helpers.branch_path(conn, :index, m.id)
  end

  def branch_names(record), do: Rabbitci.Project.branch_names(record)

  SerializerHelpers.time(inserted_at, Rabbitci.Project)
  SerializerHelpers.time(updated_at, Rabbitci.Project)
end
