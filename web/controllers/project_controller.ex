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

  def show(conn, %{"id" => id}) do
    project = Repo.one(from p in Project, where: p.id == ^id)
    conn |> assign(:projects, [project]) |> render("index.json")
  end

  def create(conn, params = %{}) do
  end

end
