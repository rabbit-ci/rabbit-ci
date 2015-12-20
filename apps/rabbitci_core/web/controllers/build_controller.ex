defmodule RabbitCICore.BuildController do
  use RabbitCICore.Web, :controller
  import Ecto.Query
  alias RabbitCICore.Build
  alias RabbitCICore.Step
  alias RabbitCICore.Repo
  alias RabbitCICore.IncomingWebhooks, as: Webhooks

  # This gets all of the currently running builds.
  # A running build is defined as:
  #   - A build that has not yet extracted its config
  #   - A build that has steps which are in the "queued" or "running" state
  #
  # The response will include the builds that are running and _all_ of its
  # steps, even the ones that are finished/failed.
  def running_builds(conn, _params) do
    builds =
      Repo.all from(b in Build,
                    join: s in assoc(b, :steps),
                    # We want to get all of the steps for all of the builds that
                    # have steps which have statuses that are either "queued" or
                    # "running". Instead of doing two queries, we load all of
                    # the steps (for preloading) here. The other join on steps
                    # is used to filter the builds that we will be loading.
                    join: sa in assoc(b, :steps),
                    join: br in assoc(b, :branch),
                    join: p in assoc(br, :project),
                    where: s.status in ["queued", "running"]
                    or b.config_extracted == "false",
                    preload: [steps: sa, branch: {br, project: p}])

    conn
    |> assign(:builds, builds)
    |> render
  end

  def start_build(conn, p = %{"name" => _, "commit" => _, "branch" => _}) do
    case Map.take(p, ["name", "commit", "branch", "pr"])
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
    |> json(%{message: "Missing params. Required: name, commit, branch."})
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
      |> Repo.one!

    conn
    |> assign(:build, build)
    |> render("show.json")
  end
end
