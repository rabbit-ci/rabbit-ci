defmodule RabbitCICore.JobView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView

  alias RabbitCICore.Job

  attributes [:name, :status, :start_time, :finish_time, :box]

  def type, do: "jobs"
end
