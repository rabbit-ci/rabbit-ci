defmodule Rabbitci.BranchSerializer do
  use Remodel

  @array_root :branches
  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :updated_at, :inserted_at, :name, :build_ids] # TODO: build_url

  def builds_ids(record), do: Rabbitci.Branch.builds_ids(record)
    # def build_url(_, conn),

  SerializerHelpers.time(updated_at, Rabbitci.Branch)
  SerializerHelpers.time(inserted_at, Rabbitci.Branch)

end
