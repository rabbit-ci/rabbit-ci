defmodule Rabbitci.ConfigExtractionController do
  use Rabbitci.Web, :controller

  plug :action

  alias Rabbitci.Repo
  alias Rabbitci.ConfigFile
  alias Rabbitci.Build

  import Ecto.Query

  def create(conn, %{"commit" => commit, "repo" => repo, "branch" => branch_name}) do
    {:ok, body, _} = read_body(conn)
    case decoded = Poison.decode(body) do
      {:ok, content} ->
        {:ok, json} = Poison.encode(content) # This removes formatting nonsense.
        build = (get_project_from_repo(repo)
                 |> get_branch(branch_name)
                 |> get_build(commit))

        # TODO: Am I using changesets right?
        config = ConfigFile.changeset(%ConfigFile{}, %{build_id: build.id, raw_body: json})
        case config.valid? do
          true ->
            Repo.insert(config)
            json(conn, %{message: "received"})
          false ->
            conn
            |> put_status(400)
            |> json(%{message: "Config has these errors: #{config.errors}"})
        end
      {:error, _} ->
        # TODO: Now we need to record that the JSON is invalid.
        conn |> put_status(400) |> json(%{message: "JSON is invalid."})
    end
  end

  defp get_build(branch, commit) do
    query = (from b in Build,
             where: b.branch_id == ^branch.id and b.commit == ^commit)
    Repo.one(query)
  end

end
