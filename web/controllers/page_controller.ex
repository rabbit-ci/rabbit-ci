defmodule Rabbitci.PageController do
  use Rabbitci.Web, :controller

  plug :action

  def index(conn, _params) do
    send_resp(conn, 200, "Server is running.")
  end
end
