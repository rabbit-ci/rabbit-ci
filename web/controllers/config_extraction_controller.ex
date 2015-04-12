defmodule Rabbitci.ConfigExtractionController do
  use Rabbitci.Web, :controller

  plug :action

  def create(conn, params) do
    {:ok, body, _} = read_body(conn)
    case decoded = Poison.decode(body) do
      {:ok, content} ->
        {:ok, json} = Poison.encode(content) # This removes formatting nonsense.
        # TODO: put JSON in DB.
        json(conn, %{message: "received"})
      {:error, _} ->
        # TODO: Now we need to record that the JSON is invalid.
        conn |> put_status(400) |> json(%{message: "JSON is invalid."})
    end
  end

end
