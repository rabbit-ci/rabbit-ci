defmodule Rabbitci.ConfigExtractionController do
  use Rabbitci.Web, :controller

  plug :action

  alias Rabbitci.Repo
  alias Rabbitci.ConfigFile
  alias Rabbitci.Build

  import Ecto.Query

  def create(conn, %{"repo" => repo, "commit" => commit, "branch" => branch_name,
                     "build_number" => build_number}) do
    {:ok, body, _} = read_body(conn)
    case Poison.decode(body) do
      {:ok, content = %{"scripts" => [_ | _]}} ->
        {:ok, json} = Poison.encode(content) # This removes formatting nonsense.
        project = get_project_from_repo(repo)
        branch = get_branch(project, branch_name)
        build = get_build(branch, build_number)

        config = ConfigFile.changeset(%ConfigFile{}, %{build_id: build.id, raw_body: json})
        case config.valid? do
          true ->
            Repo.insert(config)

            for %{"name" => script_name} <- content["scripts"] do
              Exq.enqueue(:exq, "workers", "BuildRunner", [project.name, branch.name,
                                                           build.build_number, script_name])
            end

            json(conn, %{message: "received"})
          false ->
            conn
            |> put_status(400)
            |> json(%{message: "Config has these errors: #{config.errors}"})
        end
      _ ->
        # TODO: Now we need to record that the JSON is invalid.
        conn |> put_status(400) |> json(%{message: "JSON is invalid."})
    end
  end

end
