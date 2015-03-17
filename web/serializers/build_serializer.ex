defmodule Rabbitci.BuildSerializer do
  use Remodel

  attributes [:id, :build_number, :start_time, :finish_time, :script_ids,
              :branch_id]

  def script_ids(record) do
    Rabbitci.Build.script_ids(record)
  end

end
