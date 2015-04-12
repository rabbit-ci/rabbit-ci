defmodule Rabbitci.QueueController do
  use Rabbitci.Web, :controller

  plug :action

  alias Rabbitci.Repo
  alias Rabbitci.Build
  alias Rabbitci.Branch
  alias Rabbitci.Project

  # TODO: Should this be a POST?
  # TODO: More detailed information about which parameter is missing.
  # TODO: This explodes when you attempt to provide the same branch and commit twice.
  def index(conn, %{"repo" => repo, "commit" => commit, "branch" => branch_name}) do
    case get_project_from_repo(repo) do
      nil ->
        conn |> send_resp(404, "Could not find project")
      project ->
        branch = get_branch(project, branch_name)
        latest_build_number = Build.latest_build_number(branch)
        build_number = (latest_build_number || 0) + 1 # (nil || 0) + 1 #=> 1
        build = Build.changeset(%Build{}, %{build_number: build_number, branch_id: branch.id,
                                            commit: commit})

        case build.valid? do
          true ->
            b2 = Repo.insert(build)
            Exq.enqueue(:exq, "workers", "ConfigExtractor", [repo, commit, branch_name])
            conn |> send_resp(200, "Queued")
          false ->
            conn |> send_resp(500, "Error! #{build.errors}")
        end
    end
  end

  def index(conn, _) do
    conn |> send_resp(400, '"repo", "branch", or "commit" URL parameter missing.')
  end

end
