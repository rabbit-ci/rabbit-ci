defmodule RabbitCICore.ProjectController do
  use RabbitCICore.Web, :controller
  import Ecto.Query
  alias RabbitCICore.Repo

  alias RabbitCICore.Build
  alias RabbitCICore.Project
  alias RabbitCICore.Branch

  def index(conn, _params) do # TODO: Paginate
    conn
    |> assign(:projects, Repo.all(Project))
    |> render
  end

  def show(conn, %{"name" => name}) do
    case Repo.get_by(Project, name: name) do
      nil -> send_resp(conn, 404, "Project not found.")
      project ->
        conn
        |> assign(:project, project)
        |> render
    end
  end

  plug :fix_params when action in [:start_build]
  plug :find_branch when action in [:start_build]

  @exchange Application.get_env(:rabbitci_core, :config_extraction_exchange,
                                "fake_exchange")

  def start_build(conn = %{assigns: %{branch: branch,
                                      new_params: %{repo: repo,
                                                    commit: commit,
                                                    pr: pr}}}, _params)
  do
    changeset =
      Ecto.Model.build(branch, :builds, %{commit: commit})
      |> Build.changeset

    case Repo.insert(changeset) do
      {:ok, build} ->
        add = pr && %{pr: pr} || %{commit: commit}

        config =
          Map.merge(%{repo: repo, build_id: build.id}, add)
          |> :erlang.term_to_binary

        RabbitMQ.publish(@exchange, "", config)
        json(conn, %{message: "Build queued"})
      {:error, changeset} -> reply_400(conn, Map.take(changeset, [:errors]))
    end
  end

  defp fix_params(conn = %{params: params}, []) do
    assign(conn, :new_params, _fix_params(conn, params))
  end

  defp _fix_params(_conn, params = %{"branch" => branch_name,
                                    "repo" => repo,
                                    "commit" => commit})
  do
    %{branch_name: branch_name, repo: repo, commit: commit, pr: params["pr"]}
  end

  defp _fix_params(conn, _params) do
    reply_400(conn, %{message: "Missing required params!"})
  end

  defp find_branch(conn = %{assigns:
                            %{new_params:
                              %{branch_name: branch_name, repo: repo}}}, [])
  do
    query = (
      from br in Branch,
      join: p in Project,
      on: br.project_id == p.id,
      where: br.name == ^branch_name
      and p.repo == ^repo
    )

    case Repo.one(query) do
      nil -> create_branch(conn, branch_name, repo)
      branch -> assign(conn, :branch, branch)
    end
  end

  defp create_branch(conn, branch_name, repo) do
    case create_branch(branch_name, repo) do
      {:ok, branch} -> assign(conn, :branch, branch)
      {:error, map} -> reply_400(conn, Map.take(map, [:errors]))
    end
  end

  defp create_branch(branch_name, repo) do
    case Repo.get_by(Project, repo: repo) do
      nil -> {:error, %{errors: "No project"}}
      project ->
        Ecto.Model.build(project, :branches, %{name: branch_name})
        |> Branch.changeset
        |> Repo.insert
    end
  end

  defp reply_400(conn, json_struct) do
    conn
    |> put_status(:bad_request)
    |> json(json_struct)
    |> halt
  end
end
