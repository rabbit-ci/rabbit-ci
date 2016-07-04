defmodule RabbitCICore.StepView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView

  alias RabbitCICore.{JobView, Repo}

  attributes [:name, :updated_at, :inserted_at]
  has_many :jobs, include: true, serializer: JobView

  def type, do: "steps"
  def jobs(r, _), do: Repo.preload(r, :jobs).jobs
end
