defmodule RabbitCICore.ProjectController do
  use RabbitCICore.Web, :controller
  alias RabbitCICore.Repo
  alias RabbitCICore.Project

  def index(conn, _params) do # TODO: Paginate
    conn
    |> assign(:projects, Repo.all(Project))
    |> render
  end

  def show(conn, %{"name" => name}) do
    case Repo.get_by(Project, name: name) do
      nil -> send_resp(conn, 404, "Project not found.")
      project ->
        conn
        |> assign(:project, project)
        |> render
    end
  end
end
