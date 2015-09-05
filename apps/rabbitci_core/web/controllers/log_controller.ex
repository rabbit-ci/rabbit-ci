defmodule RabbitCICore.LogController do
  use RabbitCICore.Web, :controller

  import Ecto.Query
  alias RabbitCICore.Project
  alias RabbitCICore.Repo
  alias RabbitCICore.Log

  plug :get_models

  defp get_models(conn = %{params: %{"project_name" => project_name,
                                     "branch_name" => branch_name,
                                     "build_number" => build_number}}, [])
  do
    query = from(p in Project,
                 where: p.name == ^project_name,
                 join: br in assoc(p, :branches),
                 where: br.name == ^branch_name,
                 join: b in assoc(br, :builds),
                 where: b.build_number == ^build_number,
                 select: {p, br, b})

    case Repo.one(query) do
      nil -> put_status(conn, 404) |> text("Not found!") |> halt
      {project, branch, build} ->
        conn
        |> assign(:project, project)
        |> assign(:branch, branch)
        |> assign(:build, build)
    end
  end

  def show(conn, %{"format" => "ansi"}) do
    text(conn, _log(conn))
  end

  def show(conn, %{"format" => "text"}) do
    log_text = Regex.replace(~r/\x1b\[[0-9;]*m/, _log(conn), "")
    text(conn, log_text)
  end

  def show(conn, params) do
    show(conn, Map.merge(params, %{"format" => "text"})
  end

  defp _log(%{assigns: %{project: project, branch: branch, build: build}}) do
    log_query = from(l in Log, order_by: [l.script_id, l.order])
    script_fn = fn script ->
      stdio =
        Enum.map(script.logs, &(&1.stdio))
        |> Enum.join
     """
================================================================================
"#{script.name}" -- #{project.name}/#{branch.name}##{build.build_number}

#{stdio}
     """
    end

    Repo.preload(build, [scripts: [logs: log_query]]).scripts
    |> Enum.map(script_fn)
    |> Enum.join
  end
end
