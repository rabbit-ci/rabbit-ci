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

  def show(conn, params) do
    text(conn, do_log(conn))
  end

  defp do_log(%{assigns: %{project: project, branch: branch, build: build}}) do
    job_fn = fn step, job ->
     """
================================================================================
"#{step.name}" -- #{project.name}/#{branch.name}##{build.build_number}

 #{Job.log(job)}
 """
    end

    Repo.preload(build, [steps: [jobs: :logs]]).steps
    |> Enum.map(fn step ->
      for job <- step.jobs, do: job_fn.(step, job)
    end)
    |> Enum.join
  end
end
