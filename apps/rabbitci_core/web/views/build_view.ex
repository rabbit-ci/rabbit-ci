defmodule RabbitCICore.BuildView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView

  alias RabbitCICore.Repo
  alias RabbitCICore.Build
  alias RabbitCICore.BranchView
  alias RabbitCICore.StepView

  attributes [:build_number, :start_time, :finish_time, :updated_at,
              :inserted_at, :commit, :status, :config_extracted]
  has_one :branch, include: true, serializer: BranchView
  has_many :steps, include: true, serializer: StepView

  def type, do: "builds"
  def branch(r, _), do: Repo.preload(r, :branch).branch
  def steps(r, _), do: Repo.preload(r, :steps).steps
  def status(record), do: Build.status(record)
end
