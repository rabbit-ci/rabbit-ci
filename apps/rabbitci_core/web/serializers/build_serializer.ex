defmodule RabbitCICore.BuildSerializer do
  use JaSerializer

  alias RabbitCICore.Repo
  alias RabbitCICore.Build
  alias RabbitCICore.Router.Helpers, as: RouterHelpers

  attributes [:build_number, :start_time, :finish_time,
              :updated_at, :inserted_at, :commit, :status]
  has_one :branch, link: :branch_link, field: :branch_id, type: "branches"

  def type, do: "builds"

  def branch_link(record, conn) do
    branch = Repo.preload(record, [branch: [:project]]).branch
    RouterHelpers.branch_path(conn, :show, branch.project.name, branch.name)
  end

  def status(record), do: Build.status(record)
end
