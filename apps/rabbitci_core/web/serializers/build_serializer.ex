defmodule RabbitCICore.BuildSerializer do
  require RabbitCICore.SerializerHelpers
  alias RabbitCICore.SerializerHelpers

  use JaSerializer

  serialize "builds" do
    attributes [:build_number, :start_time, :finish_time,
                :updated_at, :inserted_at, :commit, :status]
    has_one :branch, link: :branch_link, field: :branch_id, type: "branches"
  end

  def branch_link(record, conn) do
    branch = RabbitCICore.Repo.preload(record, [branch: [:project]]).branch
    RabbitCICore.Router.Helpers.branch_path(conn, :show, branch.project.name, branch.name)
  end

  def status(record), do: RabbitCICore.Build.status(record)
end
