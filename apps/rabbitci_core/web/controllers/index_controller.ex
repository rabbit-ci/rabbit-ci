defmodule RabbitCICore.IndexController do
  use RabbitCICore.Web, :controller

  def index(conn, _params) do
    text(conn, "Server is running.")
  end
end
