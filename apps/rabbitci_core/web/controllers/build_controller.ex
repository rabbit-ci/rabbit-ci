defmodule RabbitCICore.BuildController do
  use RabbitCICore.Web, :controller

  import Ecto.Query
  alias RabbitCICore.Build
  alias RabbitCICore.Branch
  alias RabbitCICore.Project
  alias RabbitCICore.Script
  alias RabbitCICore.Log
  alias RabbitCICore.Repo

  # TODO: clean this up
  defp get_parents(%{"project_name" => project_name, "branch_name" => branch_name}) do
    project = Repo.one(from p in Project, where: p.name == ^project_name)
    branch = Repo.one(from b in Branch,
                      where: b.name == ^branch_name and
                      b.project_id == ^project.id)
    {project, branch}
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
                      offset: ^(page * 30),
                      order_by: [desc: b.build_number])

    conn
    |> assign(:builds, Repo.preload(builds, [branch: [:project]]))
    |> render("index.json")
  end

  def index(conn, params) do
    index(conn, Map.merge(params, %{"page" => %{"offset" => "0"}}))
  end

  def show(conn, params = %{"build_number" => build_number}) do
    {_, branch} = get_parents(params)
    build = get_build(branch, build_number)

    conn
    |> assign(:build, Repo.preload(build, [branch: [:project]]))
    |> render("show.json")
  end
end
