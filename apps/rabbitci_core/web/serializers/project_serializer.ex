defmodule RabbitCICore.ProjectSerializer do
  use JaSerializer

  alias RabbitCICore.Project
  alias RabbitCICore.BranchSerializer
  alias RabbitCICore.Router.Helpers, as: RouterHelpers

  attributes [:name, :repo, :inserted_at,
              :updated_at]
  has_many :branches, include: BranchSerializer, link: :branches_link

  def type, do: "projects"

  def branches_link(record, conn) do
    RouterHelpers.branch_path(conn, :index, record.name)
  end

  def branches(record) do
    case Project.latest_build(record) do
      nil -> []
      build ->
        case build.branch do
          nil -> []
          a -> [a]
        end
    end
  end
end
