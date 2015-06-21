defmodule Rabbitci.BuildSerializer do
  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  use JaSerializer

  serialize "builds" do
    attributes [:build_number, :start_time, :finish_time,
                :updated_at, :inserted_at, :commit, :status]
    has_one :branch, link: ":branch_link", field: :branch_id, type: "branches"
  end

  def branch_link(record, conn) do
    branch = Rabbitci.Repo.preload(record, [branch: [:project]]).branch
    Rabbitci.Router.Helpers.branch_path(conn, :show, branch.project.name, branch.name)
  end

  def status(record), do: Rabbitci.Build.status(record)
end
