defmodule Rabbitci.BuildController do
  use Rabbitci.Web, :controller

  import Ecto.Query
  alias Rabbitci.Build

  plug :scrub_params, "build" when action in [:create, :update]
  plug :action


  def index(conn, %{"ids" => ids, "page" => page}) do
    builds = Repo.all(from b in Build,
                      where: b.id in ^ids,
                      limit: 100,
                      offset: ^(page * 100))
    conn
    |> assign(:builds, builds)
    |> render("index.json")
  end

  def index(conn, params = %{"ids" => _}) do
    index(conn, Map.merge(params, %{"page" => 0}))
  end

  def index(conn, params) do
    # I don't think this is standard. And where are the response codes?
    json(conn, %{message: "Please provide an array of ids", status: "error"})
  end


  def create(conn, %{"build" => build_params}) do
    changeset = Build.changeset(%Build{}, build_params)

    if changeset.valid? do
      Repo.insert(changeset)
      # Do someting
    else
      # Do someting
    end
  end

  def show(conn, %{"id" => id}) do
    build = Repo.get(Build, id)
    # Do someting
  end

  def edit(conn, %{"id" => id}) do
    build = Repo.get(Build, id)
    changeset = Build.changeset(build)
    # Do someting
  end

  def update(conn, %{"id" => id, "build" => build_params}) do
    build = Repo.get(Build, id)
    changeset = Build.changeset(build, build_params)

    if changeset.valid? do
      Repo.update(changeset)
      # Do someting
    else
      # Do someting
    end
  end

  def delete(conn, %{"id" => id}) do
    build = Repo.get(Build, id)
    Repo.delete(build)
    # Do someting
  end
end
