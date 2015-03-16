defmodule Rabbitci.BuildController do
  use Rabbitci.Web, :controller

  alias Rabbitci.Build

  plug :scrub_params, "build" when action in [:create, :update]
  plug :action

  def index(conn, _params) do
    builds = Repo.all(Build)
    # Do someting
  end

  def new(conn, _params) do
    changeset = Build.changeset(%Build{})
    # Do someting
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
