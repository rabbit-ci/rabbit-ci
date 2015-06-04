defmodule Rabbitci.BuildSerializer do
  require Rabbitci.SerializerHelpers
  alias Rabbitci.SerializerHelpers

  use Relax.Serializer

  serialize "builds" do
    attributes [:id, :build_number, :start_time, :finish_time,
                :updated_at, :inserted_at, :commit, :status]
    # has_many :scripts, ids: true
    has_one  :branch,  field: :branch_id
  end

  # def scripts(build, _conn), do: Rabbitci.Build.script_ids(build)
  def status(record), do: Rabbitci.Build.status(record)
end
