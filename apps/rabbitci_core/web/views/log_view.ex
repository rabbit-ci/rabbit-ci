defmodule RabbitCICore.LogView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView

  alias RabbitCICore.Log

  attributes [:stdio, :fg, :bg, :style, :type, :order]
  has_one :job, type: "job", field: :job_id
end
