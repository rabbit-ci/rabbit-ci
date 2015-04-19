defmodule Rabbitci.ProjectSerializer do
  use Remodel

  @array_root :projects

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :name, :repo, :inserted_at,
              :updated_at, :links]


  def links(record, %{conn: conn}) do
    %{branches: Rabbitci.Router.Helpers.branch_path(conn, :index, record.name)}
  end

  def id(record), do: record.name

  SerializerHelpers.time(inserted_at, Rabbitci.Project)
  SerializerHelpers.time(updated_at, Rabbitci.Project)
end
