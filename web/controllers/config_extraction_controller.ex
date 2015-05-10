defmodule Rabbitci.ConfigExtractionController do
  use Rabbitci.Web, :controller

  plug :action

  alias Rabbitci.Repo
  alias Rabbitci.ConfigFile
  alias Rabbitci.Build

  import Ecto.Query

  def create(conn, %{"repo" => repo, "commit" => commit,
                     "branch" => branch_name, "build_number" => build_number,
                     "config_string" => body}) when body != nil do
    project = get_project_from_repo(repo)
    branch = get_branch(project, branch_name)
    build = get_build(branch, build_number)

    if build == nil do
      conn |> put_status(400) |> json(%{message: "Build not found"})
    else
      config = ConfigFile.changeset(%ConfigFile{}, %{build_id: build.id,
                                                     raw_body: body})
      case config.valid? do
        true ->
          {:ok, content} = Poison.decode(body)
          Repo.insert(config)

          for %{"name" => script_name} <- content["scripts"] do
            Exq.enqueue(:exq, "workers", "BuildRunner",
                        [project.name, branch.name,
                         build.build_number, script_name])
          end

          json(conn, %{message: "received"})
        false ->
          conn
          |> put_status(400)
          |> json(%{message: "Config has errors: #{inspect config.errors}"})
      end
    end
  end

  def create(conn, params) do
    send_resp(conn, 400, "Missing params!")
  end

end
