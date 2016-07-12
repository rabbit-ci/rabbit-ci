defmodule RabbitCICore.LogView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView
  alias RabbitCICore.JobView

  attributes [:stdio, :fg, :bg, :style, :io_type, :order]
  has_one :job, serializer: JobView, field: :job_id, type: "job"

  def io_type(log, _conn), do: log.type
end
