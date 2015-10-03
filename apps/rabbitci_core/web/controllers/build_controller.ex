defmodule RabbitCICore.BuildController do
  use RabbitCICore.Web, :controller

  require Logger
  import Ecto.Query
  alias RabbitCICore.Build
  alias RabbitCICore.Branch
  alias RabbitCICore.Project
  alias RabbitCICore.Repo

  # TODO: clean this up
  defp get_parents(%{"project" => project_name, "branch" => branch_name}) do
    Logger.warn "get_parents called!"
    project = Repo.one(from p in Project, where: p.name == ^project_name)
    branch = Repo.one(from b in Branch,
                      where: b.name == ^branch_name and
                      b.project_id == ^project.id)
    {project, branch}
  end

  def index(conn, params = %{"page" => %{"offset" => page}}) do
    {_, branch} = get_parents(params)
    page = String.to_integer(page)
    builds = Repo.all(from b in Build,
                      where: b.branch_id == ^branch.id,
                      limit: 30,
                      offset: ^(page * 30),
                      order_by: [desc: b.build_number])

    conn
    |> assign(:builds, Repo.preload(builds, [branch: [:project]]))
    |> render("index.json")
  end

  def index(conn, params) do
    index(conn, Map.merge(params, %{"page" => %{"offset" => "0"}}))
  end

  def show(conn, params = %{"build_number" => build_number, "branch" => branch,
                            "project" => project}) do
    build =
    (from b in Build,
     join: br in assoc(b, :branch),
     join: p in assoc(br, :project),
     where: br.name == ^branch
     and p.name == ^project
     and b.build_number == ^build_number,
     preload: [branch: {br, project: p}])
    |> Repo.one

    case build do
      nil ->
        conn
        |> put_status(404)
        |> text("Not found.")
      _ ->
        conn
        |> assign(:build, build)
        |> render("show.json")
    end
  end
end
