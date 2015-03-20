defmodule Rabbitci.BranchController do
  use Rabbitci.Web, :controller

  import Ecto.Query
  plug :action

  def index(conn, %{"project_id" => project_id}) do
    query = from(b in Rabbitci.Branch,
                 where: b.project_id == ^project_id)
    branches = Rabbitci.Repo.all(query)

    conn
    |> assign(:branches, branches)
    |> render("index.json")
  end
end
