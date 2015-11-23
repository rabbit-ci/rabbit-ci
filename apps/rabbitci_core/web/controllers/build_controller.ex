defmodule RabbitCICore.BuildController do
  use RabbitCICore.Web, :controller
  import Ecto.Query
  alias RabbitCICore.Build
  alias RabbitCICore.Repo
  alias RabbitCICore.IncomingWebhooks, as: Webhooks

  def start_build(conn, p = %{"repo" => _, "commit" => _, "branch" => _}) do
    case Map.take(p, ["repo", "commit", "branch", "pr"])
    |> atomize_keys
    |> Webhooks.start_build do
      {:ok, build} ->
        conn
        |> assign(:build, build)
        |> render("show.json")
      {:error, reason} -> conn |> put_status(:bad_request) |> json(reason)
    end
  end
  def start_build(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Missing params. Required: repo, commit, branch."})
  end

  defp atomize_keys(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end

  def index(conn, _params = %{"branch" => branch,
                              "project" => project,
                              "page" => %{"offset" => page}}) do
    page = String.to_integer(page)
    builds =
      (from b in Build,
       join: br in assoc(b, :branch),
       join: p in assoc(br, :project),
       where: br.name == ^branch
       and p.name == ^project,
       limit: 30,
       offset: ^(page * 30),
       order_by: [desc: b.build_number],
       preload: [branch: {br, project: p}])
      |> Repo.all
      |> Repo.preload(steps: :logs)

    conn
    |> assign(:builds, builds)
    |> render("index.json")
  end

  def index(conn, params) do
    index(conn, Map.merge(params, %{"page" => %{"offset" => "0"}}))
  end

  def show(conn, _params = %{"build_number" => build_number, "branch" => branch,
                             "project" => project}) do
    build =
      (from b in Build,
       join: br in assoc(b, :branch),
       join: p in assoc(br, :project),
       where: br.name == ^branch
       and p.name == ^project
       and b.build_number == ^build_number,
       preload: [branch: {br, project: p}])
      |> Repo.one

    case build do
      nil ->
        conn
        |> put_status(404)
        |> text("Not found.")
      _ ->
        conn
        |> assign(:build, build)
        |> render("show.json")
    end
  end
end
