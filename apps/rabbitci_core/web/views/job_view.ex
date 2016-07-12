defmodule RabbitCICore.JobView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView
  alias RabbitCICore.StepView

  attributes [:name, :status, :start_time, :finish_time, :box]
  has_one :step, serializer: StepView, field: :step_id, type: "step"

  def type, do: "jobs"
end
