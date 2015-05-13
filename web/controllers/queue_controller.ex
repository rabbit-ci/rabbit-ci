defmodule Rabbitci.QueueController do
  use Rabbitci.Web, :controller

  plug :action

  alias Rabbitci.Repo
  alias Rabbitci.Build
  alias Rabbitci.Branch
  alias Rabbitci.Project

  # TODO: This will not create new branches.
  # TODO: More detailed information about which parameter is missing.
  # TODO: This explodes when you attempt to provide the same branch and commit twice.
  #       Solve by giving the extractor a build id?
  def create(conn, %{"repo" => repo, "commit" => commit, "branch" => branch_name}) do
    case get_project_from_repo(repo) do
      nil ->
        conn |> send_resp(404, "Could not find project")
      project ->
        branch = get_branch(project, branch_name)

        if branch == nil do
          branch = Branch.changeset(%Branch{}, %{name: branch_name,
                                       project_id: project.id,
                                       exists_in_git: true})
          |> Repo.insert
        end

        latest_build = Build.latest_build_on_branch(branch)
        build_number = ((latest_build && latest_build.build_number) || 0) + 1
        # (nil || 0) + 1 #=> 1
        build = Build.changeset(%Build{}, %{build_number: build_number,
                                            branch_id: branch.id,
                                            commit: commit})
        case build.valid? do
          true ->
            Repo.insert(build)
            Exq.enqueue(:exq, "workers", "ConfigExtractor", [repo, commit,
                                                             branch_name,
                                                             build_number])
            conn |> send_resp(200, "Queued")
          false ->
            conn |> send_resp(500, "Error! #{build.errors}")
        end
    end
  end

  def create(conn, _) do
    conn |> send_resp(400, '"repo", "branch", or "commit" URL parameter missing.')
  end

end
