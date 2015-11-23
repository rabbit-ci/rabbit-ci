defmodule RabbitCICore.IndexController do
  use RabbitCICore.Web, :controller
  import Ecto.Query
  alias RabbitCICore.Build
  alias RabbitCICore.Step
  alias RabbitCICore.Repo

  def index(conn, _params) do
    send_resp(conn, 200, "Server is running.")
  end

  def running_builds(conn, _params) do
    builds =
      Repo.all from(b in Build,
                    join: s in assoc(b, :steps),
                    join: br in assoc(b, :branch),
                    join: p in assoc(br, :project),
                    where: s.status in ["queued", "running"]
                    or b.config_extracted == "false",
                    preload: [steps: s, branch: {br, project: p}])

    conn
    |> assign(:builds, builds)
    |> render
  end
end
