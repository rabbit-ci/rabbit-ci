defmodule Rabbitci.ProjectSerializer do
  use Relax.Serializer

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  serialize "projects" do
    attributes [:id, :name, :repo, :inserted_at,
                :updated_at]
    has_many :branches, serializer: Rabbitci.BranchSerializer
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
