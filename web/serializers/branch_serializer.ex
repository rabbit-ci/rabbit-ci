defmodule Rabbitci.BranchSerializer do
  use Remodel

  @array_root :branches
  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :updated_at, :inserted_at, :name]

  def id(record), do: record.name

  # TODO: Fix this.
  # def build_url(m, conn) do
  #   IO.inspect conn
  #   Rabbitci.Router.Helpers.build_path(conn, :index, m.project_id, m.id)
  # end

  SerializerHelpers.time(updated_at, Rabbitci.Branch)
  SerializerHelpers.time(inserted_at, Rabbitci.Branch)

end
