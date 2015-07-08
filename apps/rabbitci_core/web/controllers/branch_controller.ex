defmodule RabbitCICore.BranchController do
  use RabbitCICore.Web, :controller

  import Ecto.Query
  alias RabbitCICore.Project

  defp get_project_id(%{"project_name" => project_name}) do
    Repo.one(from p in Project, where: p.name == ^project_name).id
  end

  def index(conn, params) do
    query = from(b in RabbitCICore.Branch,
                 where: b.project_id == ^get_project_id(params))
    branches = RabbitCICore.Repo.all(query)

    conn
    |> assign(:branches, branches)
    |> render("index.json")
  end

  def show(conn, params = %{"name" => name}) do
    branch = Repo.one(from b in RabbitCICore.Branch,
                      where: b.name == ^name and
                      b.project_id == ^get_project_id(params))
    case branch do
      nil -> conn |> send_resp(404, "Branch not found.")
      _ -> conn |> assign(:branch, branch) |> render("show.json")
    end
  end
end
