defmodule Rabbitci.ConfigExtractionController do
  use Rabbitci.Web, :controller

  plug :action

  def create(conn, params) do
    {:ok, body, _} = read_body(conn)
    conn |> json(%{message: "received"})
  end

end
