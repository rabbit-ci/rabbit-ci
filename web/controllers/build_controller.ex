defmodule Rabbitci.BuildController do
  use Rabbitci.Web, :controller

  import Ecto.Query
  alias Rabbitci.Build
  alias Rabbitci.Branch
  alias Rabbitci.Project

  plug :action

  defp get_ids(%{"project_name" => project_name, "branch_name" => branch_name}) do
    project_id = Repo.one(from p in Project, where: p.name == ^project_name).id
    branch_id = Repo.one(from b in Branch,
                         where: b.name == ^branch_name and
                         b.project_id == ^project_id).id
    {project_id, branch_id}
  end

  def index(conn, params = %{"page" => %{"offset" => page}}) do
    {project_id, branch_id} = get_ids(params)
    page = String.to_integer(page)
    builds = Repo.all(from b in Build,
                      where: b.branch_id == ^branch_id,
                      limit: 30,
                      offset: ^(page * 30))

    conn
    |> assign(:builds, builds)
    |> render("index.json")
  end

  def index(conn, params) do
    index(conn, Map.merge(params, %{"page" => %{"offset" => "0"}}))
  end

  def create(conn, %{"build" => build_params}) do
    changeset = Build.changeset(%Build{}, build_params)

    if changeset.valid? do
      Repo.insert(changeset)
      # Do someting
    else
      # Do someting
    end
  end

  def show(conn, params = %{"build_number" => build_number}) do
    {project_id, branch_id} = get_ids(params)
    build = Repo.all(from b in Build,
                     where: b.build_number == ^build_number and
                     b.branch_id == ^branch_id)

    conn
    |> assign(:build, build)
    |> render("show.json")
  end

  def edit(conn, %{"id" => id}) do
    build = Repo.get(Build, id)
    changeset = Build.changeset(build)
    # Do someting
  end

  def update(conn, %{"id" => id, "build" => build_params}) do
    build = Repo.get(Build, id)
    changeset = Build.changeset(build, build_params)

    if changeset.valid? do
      Repo.update(changeset)
      # Do someting
    else
      # Do someting
    end
  end

  def delete(conn, %{"id" => id}) do
    build = Repo.get(Build, id)
    Repo.delete(build)
    # Do someting
  end
end
