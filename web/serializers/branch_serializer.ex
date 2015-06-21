defmodule Rabbitci.BranchSerializer do
  use JaSerializer

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  serialize "branches" do
    attributes [:updated_at, :inserted_at, :name]
    has_one :project, link: ":project_link", field: :project_id, type: "projects"
    has_many :builds, include: Rabbitci.BuildSerializer, link: ":builds_link"
  end

  def project_link(record, conn) do
    project = Rabbitci.Repo.preload(record, [:project]).project
    Rabbitci.Router.Helpers.project_path(conn, :show, project.name)
  end

  def builds_link(record, conn) do
    project = Rabbitci.Repo.preload(record, [:project]).project
    Rabbitci.Router.Helpers.build_path(conn, :index, project.name, record.name)
  end

  def builds(record) do
    (Rabbitci.Branch.latest_build(record) || []) |> List.wrap
  end
end
