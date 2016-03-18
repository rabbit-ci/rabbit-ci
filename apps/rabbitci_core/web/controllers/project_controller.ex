defmodule RabbitCICore.ProjectController do
  use RabbitCICore.Web, :controller
  alias RabbitCICore.Repo
  alias RabbitCICore.Project

  def index(conn, %{"name" => name}) do
    project = Repo.get_by!(Project, name: name)
    conn
    |> render(data: project)
  end

  def index(conn, _params) do # TODO: Paginate
    conn
    |> render(data: Repo.all(Project))
  end
end
