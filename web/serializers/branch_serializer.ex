defmodule Rabbitci.BranchSerializer do
  use Remodel

  @array_root :branches
  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :updated_at, :inserted_at, :name, :latest_build, :builds]

  def id(record), do: record.name

  def latest_build(record) do
    latest = Rabbitci.Branch.latest(record)
    if latest != nil do
      latest.id
    else
      nil
    end
  end

  def builds(record) do
    case [latest_build(record)] do
      a = [nil] -> []
      a = _ -> a
    end
  end

  # TODO: Fix this.
  # def build_url(m, conn) do
  #   IO.inspect conn
  #   Rabbitci.Router.Helpers.build_path(conn, :index, m.project_id, m.id)
  # end

  SerializerHelpers.time(updated_at, Rabbitci.Branch)
  SerializerHelpers.time(inserted_at, Rabbitci.Branch)

end
