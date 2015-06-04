defmodule Rabbitci.BranchSerializer do
  # use Remodel
  use Relax.Serializer

  # @array_root :branches
  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  serialize "branches" do
    attributes [:id, :updated_at, :inserted_at, :name]
    has_one :project, field: :project_id
    # has_one :latest_build
    has_many :builds, serializer: Rabbitci.BuildSerializer
  end

  def builds(record) do
    (Rabbitci.Branch.latest(record) || []) |> List.wrap
  end

  # def builds(record) do
  #   case Rabbitci.Branch.latest(record) do
  #     nil -> []
  #     a -> a
  #   end
  # end
end
