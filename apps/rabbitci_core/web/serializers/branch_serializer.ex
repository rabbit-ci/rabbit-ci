defmodule RabbitCICore.BranchSerializer do
  use JaSerializer

  alias RabbitCICore.Repo
  alias RabbitCICore.Branch
  alias RabbitCICore.BuildSerializer
  alias RabbitCICore.Router.Helpers, as: RouterHelpers

  attributes [:updated_at, :inserted_at, :name]
  has_one :project, link: :project_link, field: :project_id, type: "projects"
  has_many :builds, include: BuildSerializer, link: :builds_link

  def type, do: "branches"

  def project_link(record, conn) do
    project = Repo.preload(record, [:project]).project
    RouterHelpers.project_path(conn, :show, project.name)
  end

  def builds_link(record, conn) do
    project = Repo.preload(record, [:project]).project
    RouterHelpers.build_path(conn, :index, project.name, record.name)
  end

  def builds(record) do
    (Branch.latest_build(record) || []) |> List.wrap
  end
end
