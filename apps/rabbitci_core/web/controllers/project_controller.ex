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

  def create(conn, %{"data" => %{"attributes" => project_params}}) do
    changeset = Project.changeset(%Project{}, project_params)

    case Repo.insert(changeset) do
      {:ok, project} ->
        conn
        |> put_status(:created)
        |> render(:show, data: project)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, data: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    project = Repo.get!(Project, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(project)

    send_resp(conn, :no_content, "")
  end
end
