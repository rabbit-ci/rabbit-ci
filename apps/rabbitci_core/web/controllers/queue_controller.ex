defmodule RabbitCICore.QueueController do
  use RabbitCICore.Web, :controller

  alias RabbitCICore.Repo
  alias RabbitCICore.Build
  alias RabbitCICore.Branch
  alias RabbitCICore.Project

  # TODO: More detailed information about which parameter is missing.
  def create(conn, %{"repo" => repo, "commit" => commit,
                     "branch" => branch_name}) do
    _create(conn, %{project: get_project_from_repo(repo),
                    branch_name: branch_name,
                    commit: commit,
                    repo: repo})
  end

  def create(conn, _) do
    conn |> send_resp(400, '"repo", "branch", or "commit" URL parameter missing.')
  end

  defp _create(conn, %{project: nil}) do
    conn |> send_resp(404, "Could not find project")
  end

  defp _create(conn, args = %{branch_name: branch_name, project: project,
                              branch: nil}) do
    branch =
      Branch.changeset(%Branch{}, %{name: branch_name, project_id: project.id,
                                    exists_in_git: true})
      |> Repo.insert!
    _create(conn, Map.merge(args, %{branch: branch}))
  end

  defp _create(conn, %{repo: repo, branch_name: branch_name, build: build,
                       valid: true}) do
    build = Repo.insert!(build)
    Exq.enqueue(:exq, "workers", "ConfigExtractor", [repo, build.commit,
                                                     branch_name,
                                                     build.build_number])
    conn |> send_resp(200, "Queued")
  end

  defp _create(conn, %{build: build, valid: false}) do
    conn |> send_resp(500, "Error! #{build.errors}")
  end

  defp _create(conn, args = %{commit: commit, branch: branch = %Branch{}}) do
    latest_build = Branch.latest_build(branch)
    build_number = ((latest_build && latest_build.build_number) || 0) + 1
    # (nil || 0) + 1 #=> 1
    build = Build.changeset(%Build{}, %{build_number: build_number,
                                        branch_id: branch.id, commit: commit})
    _create(conn, Map.merge(args, %{build: build, valid: build.valid?}))
  end

  defp _create(conn, args = %{branch_name: branch_name,
                              project: project = %Project{}}) do
    branch = get_branch(project, branch_name)
    _create(conn, Map.merge(args, %{branch: branch}))
  end
end
