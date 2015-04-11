defmodule Rabbitci.QueueController do
  use Rabbitci.Web, :controller

  plug :action

  def index(conn, _params) do
    conn |> send_resp(200, "Kewl")
  end

end
