defmodule Rabbitci.ControllerHelpers do
  import Ecto.Query

  alias Rabbitci.Repo
  alias Rabbitci.Branch
  alias Rabbitci.Project

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
end
