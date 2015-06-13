defmodule Rabbitci.BranchSerializer do
  use Relax.Serializer

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  serialize "branches" do
    attributes [:id, :updated_at, :inserted_at, :name]
    has_one :project, field: :project_id
    has_many :builds, serializer: Rabbitci.BuildSerializer
  end

  def builds(record) do
    (Rabbitci.Branch.latest_build(record) || []) |> List.wrap
  end
end
