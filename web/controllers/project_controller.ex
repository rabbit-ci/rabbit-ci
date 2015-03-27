defmodule Rabbitci.ProjectController do
  use Rabbitci.Web, :controller

  import Ecto.Query

  alias Rabbitci.Build
  alias Rabbitci.Branch
  alias Rabbitci.Project
  alias Rabbitci.Repo

  plug :action

  def index(conn, params) do # This will be paginated later
    projects = Repo.all(Project)
    conn
    |> assign(:projects, projects)
    |> render("index.json")
  end

  def show(conn, %{"id" => name}) do
    project = Repo.one(from p in Project, where: p.name == ^name)
    conn |> assign(:project, project) |> render("show.json")
  end

  def create(conn, params = %{}) do
  end

end
