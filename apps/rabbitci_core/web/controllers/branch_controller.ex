defmodule RabbitCICore.BranchController do
  use RabbitCICore.Web, :controller

  import Ecto.Query
  alias RabbitCICore.Branch

  def show(conn, %{"project" => project_name, "branch" => branch_name}) do
    branch =
      from(b in branch_query(project_name), where: b.name == ^branch_name)
      |> Repo.one!

    conn
    |> assign(:branch, branch)
  end

  def index(conn, %{"project" => project_name}) do
    branches = branch_query(project_name) |> Repo.all

    conn
    |> assign(:branches, branches)
    |> render
  end

  defp branch_query(project_name) do
    from(b in Branch,
         join: p in assoc(b, :project),
         where: p.name == ^project_name)
  end
end
