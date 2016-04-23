defmodule RabbitCICore.LogController do
  use RabbitCICore.Web, :controller

  import Ecto.Query
  alias RabbitCICore.Project
  alias RabbitCICore.Repo
  alias RabbitCICore.Job
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
      nil ->
        conn
        |> put_status(404)
        |> text("Not found!")
        |> halt
      {project, branch, build} ->
        conn
        |> assign(:project, project)
        |> assign(:branch, branch)
        |> assign(:build, build)
    end
  end

  def show(conn, %{"format" => "ansi"}) do
    log = do_log(conn)
    text(conn, log)
  end
  def show(conn, %{"format" => "text"}) do
    # We're cleaning it _after_ we concat all the logs because the job name
    # could possibly include some ANSI codes.
    log = Job.clean_log do_log(conn)
    text(conn, log)
  end
  def show(conn, params) do
    show(conn, Map.merge(params, %{"format" => "text"}))
  end

  defp do_log(%{assigns: %{project: project, branch: branch, build: build}}) do
    job_fn = fn job ->
     """
================================================================================
"#{job.name}" -- #{project.name}/#{branch.name}##{build.build_number}

 #{Job.log(job, :no_clean)}
 """
    end

    Repo.preload(build, [jobs: :logs]).jobs
    |> Enum.map(job_fn)
    |> Enum.join
  end
end
