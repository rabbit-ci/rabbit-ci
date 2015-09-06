defmodule RabbitCICore.BranchSerializer do
  use JaSerializer

  alias RabbitCICore.Repo
  alias RabbitCICore.Branch
  alias RabbitCICore.BuildSerializer
  alias RabbitCICore.ProjectSerializer

  attributes [:updated_at, :inserted_at, :name]
  has_one :project, include: ProjectSerializer
  has_many :builds, include: BuildSerializer

  def type, do: "branches"

  def project(r, _), do: Repo.preload(r, :project).project
  def builds(record, _) do
    (Branch.latest_build(record) || []) |> List.wrap
  end
end
