defmodule RabbitCICore.BranchView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView
  alias RabbitCICore.Repo
  alias RabbitCICore.ProjectView
  alias RabbitCICore.Router.Helpers, as: RouterHelpers

  attributes [:updated_at, :inserted_at, :name]
  has_one :project, include: true, serializer: ProjectView
  has_many :builds, link: :builds_link

  def type, do: "branches"
  def project(r, _), do: Repo.preload(r, :project).project

  def builds_link(record, conn) do
    record = Repo.preload(record, :project)
    RouterHelpers.build_path(conn, :index, %{branch: record.name,
                                             project: record.project.name})
  end
end
