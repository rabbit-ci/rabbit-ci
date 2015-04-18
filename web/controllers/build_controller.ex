defmodule Rabbitci.BuildController do
  use Rabbitci.Web, :controller

  import Ecto.Query
  alias Rabbitci.Build
  alias Rabbitci.Branch
  alias Rabbitci.Project

  plug :action

  # TODO: clean this up
  defp get_parents(%{"project_name" => project_name, "branch_name" => branch_name}) do
    project = Repo.one(from p in Project, where: p.name == ^project_name)
    branch = Repo.one(from b in Branch,
                         where: b.name == ^branch_name and
                         b.project_id == ^project.id)
    {project, branch}
  end

  def config_file(conn, params = %{"build_number" => build_number}) do
    {project, branch} = get_parents(params)
    build = Rabbitci.Repo.preload(get_build(branch, build_number), :config_file)
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, build.config_file.raw_body)
  end

  def index(conn, params = %{"page" => %{"offset" => page}}) do
    {_, branch} = get_parents(params)
    page = String.to_integer(page)
    builds = Repo.all(from b in Build,
                      where: b.branch_id == ^branch.id,
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
    {_, branch} = get_parents(params)
    build = get_build(branch, build_number)

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
