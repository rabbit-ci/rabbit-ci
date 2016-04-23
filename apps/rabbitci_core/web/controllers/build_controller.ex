defmodule RabbitCICore.BuildController do
  use RabbitCICore.Web, :controller
  import Ecto.Query
  alias RabbitCICore.{Build, Job, Repo, Project}
  alias RabbitCICore.IncomingWebhooks, as: Webhooks

  # This gets all of the currently running builds.
  # A running build is defined as:
  #   - A build that has not yet extracted its config
  #   - A build that has jobs which are in the "queued" or "running" state
  #
  # The response will include the builds that are running and _all_ of its
  # jobs, even the ones that are finished/failed.
  def running_builds(conn, _params) do
    builds =
      Repo.all from(b in Build,
                    join: s in assoc(b, :jobs),
                    # We want to get all of the jobs for all of the builds that
                    # have jobs which have statuses that are either "queued" or
                    # "running". Instead of doing two queries, we load all of
                    # the jobs (for preloading) here. The other join on jobs
                    # is used to filter the builds that we will be loading.
                    join: sa in assoc(b, :jobs),
                    join: br in assoc(b, :branch),
                    join: p in assoc(br, :project),
                    where: s.status in ["queued", "running"]
                    or b.config_extracted == "false",
                    preload: [jobs: sa, branch: {br, project: p}])

    conn
    |> render("index.json", data: builds)
  end

  def start_build(conn, params = %{"name" => name,
                                   "commit" => _,
                                   "branch" => _,
                                   "webhook_secret" => secret}) do
    # If the webhook secret is incorrect, this will return 404.
    Repo.get_by!(Project, [name: name, webhook_secret: secret])
    case params
    |> Map.take(["name", "commit", "branch", "pr"])
    |> atomize_keys!
    |> Webhooks.start_build do
      {:ok, build} ->
        conn
        |> render("show.json", data: build)
      {:error, reason} ->
        conn
        |> put_status(:bad_request)
        |> json(reason)
    end
  end
  def start_build(conn, _) do
    conn
    |> put_status(:bad_request)
    |> json(%{message: "Missing params. Required: name, commit, branch, webhook_secret."})
  end

  # WARNING: This function can be very dangerous.
  #
  # Do NOT atomize maps whose keys have not been filtered. Atoms are not garbage
  # collected and this can lead to a DoS attack. Use carefully.
  defp atomize_keys!(map) do
    for {key, val} <- map, into: %{}, do: {String.to_atom(key), val}
  end

  # This route will *NOT* provide log output. You must fetch a *SINGLE* build if
  # you want the logs.
  def index(conn, _params = %{"branch" => branch,
                              "project" => project,
                              "page" => %{"offset" => page}}) do
    page = String.to_integer(page)
    query = from b in Build,
           join: br in assoc(b, :branch),
           join: p in assoc(br, :project),
          where: br.name == ^branch
             and p.name == ^project,
          limit: 30,
         offset: ^(page * 30),
       order_by: [desc: b.build_number],
        preload: [branch: {br, project: p}]

    builds =
      query
      |> Repo.all
      |> Repo.preload(:jobs)

    render(conn, data: builds, no_logs: true)
  end

  def index(conn, %{"build_number" => "latest",
                    "branch" => branch,
                    "project" => project}) do
    query = from b in Build,
           join: br in assoc(b, :branch),
           join: p in assoc(br, :project),
          where: br.name == ^branch
             and p.name == ^project,
       order_by: [desc: b.build_number],
          limit: 1,
        preload: [branch: {br, project: p}]

    build = Repo.one! query
    render(conn, data: build)
  end

  def index(conn, %{"build_number" => build_number,
                    "branch" => branch,
                    "project" => project}) do
    query = from b in Build,
           join: br in assoc(b, :branch),
           join: p in assoc(br, :project),
          where: br.name == ^branch
             and p.name == ^project
             and b.build_number == ^build_number,
         preload: [branch: {br, project: p}]

    build = Repo.one! query
    render(conn, data: build)
  end

  def index(conn, params) do
    case params["page"] do
      nil -> index(conn, Map.merge(params, %{"page" => %{"offset" => "0"}}))
      _ -> send_resp(conn, :not_found, "")
    end
  end
end
