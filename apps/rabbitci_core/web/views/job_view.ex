defmodule RabbitCICore.JobView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView

  attributes [:name, :status, :start_time, :finish_time, :box]
  def type, do: "jobs"
end
