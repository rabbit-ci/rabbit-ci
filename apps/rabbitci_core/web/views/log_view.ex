defmodule RabbitCICore.LogView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView

  attributes [:stdio, :fg, :bg, :style, :io_type, :order]
  has_one :job, type: "job", field: :job_id

  def io_type(log, conn), do: log.type
end
