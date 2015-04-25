defmodule Rabbitci.ControllerHelpers do
  import Ecto.Query

  alias Rabbitci.Repo
  alias Rabbitci.Branch
  alias Rabbitci.Project
  alias Rabbitci.Build

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
    Build.latest_build_on_branch(branch)
  end

  def get_build(branch, build_number) do
    query = (from b in Build,
             where: b.branch_id == ^branch.id
             and b.build_number == ^build_number)
    Repo.one(query)
  end
end
