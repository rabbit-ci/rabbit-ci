defmodule Rabbitci.PageController do
  use Rabbitci.Web, :controller

  plug :action

  def index(conn, _params) do
    render conn, "index.html"
  end
end
