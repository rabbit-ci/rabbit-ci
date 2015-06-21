defmodule Rabbitci.BuildSerializer do
  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  use JaSerializer

  serialize "builds" do
    attributes [:build_number, :start_time, :finish_time,
                :updated_at, :inserted_at, :commit, :status]
    has_one :branch, link: ":branch_link"
  end

  def branch_link(record, conn) do
    branch = Rabbitci.Repo.preload(record, [branch: [:project]]).branch
    Rabbitci.Router.Helpers.branch_path(conn, :show, branch.project, branch)
  end

  def status(record), do: Rabbitci.Build.status(record)
end
