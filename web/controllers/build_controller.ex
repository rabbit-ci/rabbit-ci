defmodule Rabbitci.BuildController do
  use Rabbitci.Web, :controller

  import Ecto.Query
  alias Rabbitci.Build
  alias Rabbitci.Branch
  alias Rabbitci.Project
  alias Rabbitci.Script
  alias Rabbitci.Log

  plug :action

  # TODO: clean this up
  defp get_parents(%{"project_name" => project_name, "branch_name" => branch_name}) do
    project = Repo.one(from p in Project, where: p.name == ^project_name)
    branch = Repo.one(from b in Branch,
                         where: b.name == ^branch_name and
                         b.project_id == ^project.id)
    {project, branch}
  end

  def log_put(conn, params = %{"build_number" => build_number,
                               "script" => script_name,
                               "log_string" => body}) do
    {_, branch} = get_parents(params)
    build = Repo.preload(get_build(branch, build_number), :scripts)
    case Enum.find(build.scripts, fn(script) -> script.name == script_name end) do
      nil ->
        script = Repo.insert(%Script{name: script_name, status: "running", build_id: build.id})
        Repo.insert(%Log{stdio: body, script_id: script.id})
      script ->
        log = Repo.preload(script, :log).log
        Repo.update(%{log | stdio: log.stdio <> body})
    end

    conn |> send_resp(200, "Hopefully this worked.")
  end

  def log_get(conn, params = %{"build_number" => build_number}) do
    {_, branch} = get_parents(params)
    build = Repo.preload(get_build(branch, build_number), scripts: [:log])

    log_str = Enum.map(build.scripts, fn(script) ->
      "--> Begin #{script.name} log\n"
      <> script.log.stdio
      <> "--> End #{script.name} log\n\n"
    end) |> Enum.join

    conn |> send_resp(200, log_str)
  end

  def config(conn, params = %{"build_number" => build_number}) do
    {project, branch} = get_parents(params)
    build = Repo.preload(get_build(branch, build_number), :config_file)
    conn
    |> assign(:build, build)
    |> assign(:branch, branch)
    |> assign(:project, project)
    |> render("config.json")
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

  def show(conn, params = %{"build_number" => build_number}) do
    {_, branch} = get_parents(params)
    build = get_build(branch, build_number)

    conn
    |> assign(:build, build)
    |> render("show.json")
  end

  # def update(conn, %{"id" => id, "build" => build_params}) do
  #   build = Repo.get(Build, id)
  #   changeset = Build.changeset(build, build_params)

  #   if changeset.valid? do
  #     Repo.update(changeset)
  #     # Do someting
  #   else
  #     # Do someting
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   build = Repo.get(Build, id)
  #   Repo.delete(build)
  #   # Do someting
  # end
end
