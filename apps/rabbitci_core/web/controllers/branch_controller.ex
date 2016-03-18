defmodule RabbitCICore.BranchController do
  use RabbitCICore.Web, :controller

  import Ecto.Query
  alias RabbitCICore.Branch

  def index(conn, %{"project" => project_name, "branch" => branch_name}) do
    branch = Repo.get_by!(branch_query(project_name), name: branch_name)

    conn
    |> render(data: branch)
  end

  def index(conn, %{"project" => project_name}) do
    branches = Repo.all branch_query(project_name)

    conn
    |> render(data: branches)
  end

  def branch_query(project_name) do
      from b in Branch,
     join: p in assoc(b, :project),
    where: p.name == ^project_name
  end
end
