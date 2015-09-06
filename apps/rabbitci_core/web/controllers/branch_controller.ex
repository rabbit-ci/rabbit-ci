defmodule RabbitCICore.BranchController do
  use RabbitCICore.Web, :controller

  import Ecto.Query
  alias RabbitCICore.Project
  alias RabbitCICore.Branch

  def index(conn, %{"project" => project_name}) do
    branches =
      from(b in Branch,
           join: p in assoc(b, :project),
           where: p.name == ^project_name)
      |> Repo.all

      conn
      |> assign(:branches, branches)
      |> render
  end

  def show(conn, %{"project" => project_name, "branch" => branch_name}) do
    branch =
      from(b in Branch,
           join: p in assoc(b, :project),
           where: p.name == ^project_name,
           where: b.name == ^branch_name)
      |> Repo.one

    case branch do
      nil -> send_resp(conn, 404, "Not found.")
      branch ->
        conn
        |> assign(:branch, branch)
        |> render
    end
  end
end
