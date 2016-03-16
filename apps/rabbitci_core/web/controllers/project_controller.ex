defmodule RabbitCICore.ProjectController do
  use RabbitCICore.Web, :controller
  alias RabbitCICore.Repo
  alias RabbitCICore.Project

  def index(conn, %{"name" => name}) do
    project = Repo.get_by!(Project, name: name)
    conn
    |> assign(:project, project)
    |> render
  end

  def index(conn, _params) do # TODO: Paginate
    conn
    |> assign(:projects, Repo.all(Project))
    |> render
  end
end
