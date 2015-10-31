defmodule RabbitCICore.BuildSerializer do
  use JaSerializer

  alias RabbitCICore.Repo
  alias RabbitCICore.Build
  alias RabbitCICore.BranchSerializer

  attributes [:build_number, :start_time, :finish_time, :updated_at,
              :inserted_at, :commit, :status, :config_extracted]
  has_one :branch, include: BranchSerializer

  def type, do: "builds"

  def branch(r, _), do: Repo.preload(r, :branch).branch
  def status(record), do: Build.status(record)
end
