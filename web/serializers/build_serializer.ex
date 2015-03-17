defmodule Rabbitci.BuildSerializer do
  use Remodel

  attributes [:id, :build_number, :start_time, :finish_time, :script_ids,
              :branch_id]

  def script_ids(record) do
    Rabbitci.Build.script_ids(record)
  end

  def start_time(%Rabbitci.Build{start_time: nil}), do: nil
  def start_time(r), do: Ecto.DateTime.to_string(r.start_time)
  def finish_time(%Rabbitci.Build{finish_time: nil}), do: nil
  def finish_time(r), do: Ecto.DateTime.to_string(r.finish_time)

end
