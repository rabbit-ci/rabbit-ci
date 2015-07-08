defmodule RabbitCICore.IndexController do
  use RabbitCICore.Web, :controller

  def index(conn, _params) do
    send_resp(conn, 200, "Server is running.")
  end
end
