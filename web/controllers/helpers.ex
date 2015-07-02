defmodule RabbitCICore.ControllerHelpers do
  import Ecto.Query

  alias RabbitCICore.Repo
  alias RabbitCICore.Branch
  alias RabbitCICore.Project
  alias RabbitCICore.Build

  def get_branch(project, branch_name) do
    query = (from b in Branch,
             where: b.name == ^branch_name and b.project_id == ^project.id)
    Repo.one(query)
  end

  def get_project_from_repo(repo) do
    query = (from p in Project,
             where: p.repo == ^repo)
    Repo.one(query)
  end

  def get_build(branch, "latest") do
    Branch.latest_build(branch)
  end

  def get_build(branch, build_number) do
    query = (from b in Build,
             where: b.branch_id == ^branch.id
             and b.build_number == ^build_number)
    Repo.one(query)
  end
end
