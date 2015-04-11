defmodule Rabbitci.QueueController do
  use Rabbitci.Web, :controller

  plug :action

  def index(conn, %{"repo" => repo, "commit" => commit}) do
    Exq.enqueue(:exq, "workers", "ConfigExtractor", [repo, commit])
    conn |> send_resp(200, "Queued")
  end

  def index(conn, _) do
    conn |> send_resp(400, '"repo" or "commit" URL parameter missing.')
  end

end
