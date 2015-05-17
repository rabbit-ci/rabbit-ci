defmodule Rabbitci.BuildSerializer do
  use Remodel

  @array_root :builds
  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :build_number, :start_time, :finish_time, :script_ids,
              :branch_id, :updated_at, :inserted_at, :commit] # need script path

  def script_ids(record), do: Rabbitci.Build.script_ids(record)

  SerializerHelpers.time(start_time, Rabbitci.Build)
  SerializerHelpers.time(finish_time, Rabbitci.Build)
  SerializerHelpers.time(inserted_at, Rabbitci.Build)
  SerializerHelpers.time(updated_at, Rabbitci.Build)

end
