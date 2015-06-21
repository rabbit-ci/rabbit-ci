defmodule Rabbitci.ProjectSerializer do
  use JaSerializer

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  serialize "projects" do
    attributes [:name, :repo, :inserted_at,
                :updated_at]
    has_many :branches, include: Rabbitci.BranchSerializer, link: ":branches_link"
  end

  def branches_link(record, conn) do
    Rabbitci.Router.Helpers.branch_path(conn, :index, record.name)
  end

  def branches(record) do
    case Rabbitci.Project.latest_build(record) do
      nil -> []
      build ->
        case build.branch do
          nil -> []
          a -> [a]
        end
    end
  end
end
