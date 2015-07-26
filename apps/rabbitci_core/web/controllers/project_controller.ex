defmodule RabbitCICore.ProjectController do
  use RabbitCICore.Web, :controller

  import Ecto.Query

  alias RabbitCICore.Project
  alias RabbitCICore.Repo

  def index(conn, params) do # This will be paginated later
    projects = Repo.all(Project)
    conn
    |> assign(:projects, projects)
    |> render("index.json")
  end

  def show(conn, %{"id" => name}) do
    project = Repo.one(from p in Project, where: p.name == ^name)
    case project do
      nil -> conn |> send_resp(404, "Project not found.")
      _ -> conn |> assign(:project, project) |> render("show.json")
    end
  end

  def create(conn, params = %{}) do
  end

end
