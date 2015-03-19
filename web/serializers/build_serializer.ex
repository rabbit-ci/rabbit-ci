defmodule Rabbitci.BuildSerializer do
  use Remodel

  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  attributes [:id, :build_number, :start_time, :finish_time, :script_ids,
              :branch_id] # We also need timestamps

  def script_ids(record), do: Rabbitci.Build.script_ids(record)

  SerializerHelpers.time(start_time, Rabbitci.Build)
  SerializerHelpers.time(finish_time, Rabbitci.Build)

end
