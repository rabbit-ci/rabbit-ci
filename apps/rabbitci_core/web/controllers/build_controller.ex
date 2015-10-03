defmodule RabbitCICore.BuildController do
  use RabbitCICore.Web, :controller

  require Logger
  import Ecto.Query
  alias RabbitCICore.Build
  alias RabbitCICore.Branch
  alias RabbitCICore.Project
  alias RabbitCICore.Repo

  def index(conn, params = %{"branch" => branch,
                             "project" => project,
                             "page" => %{"offset" => page}}) do
    page = String.to_integer(page)
    builds =
      (from b in Build,
       join: br in assoc(b, :branch),
       join: p in assoc(br, :project),
       where: br.name == ^branch
       and p.name == ^project,
       limit: 30,
       offset: ^(page * 30),
       order_by: [desc: b.build_number],
       preload: [:scripts, branch: {br, project: p}])
      |> Repo.all

    conn
    |> assign(:builds, builds)
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
