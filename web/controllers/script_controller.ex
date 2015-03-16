defmodule Rabbitci.ScriptController do
  use Rabbitci.Web, :controller

  alias Rabbitci.Script

  plug :scrub_params, "script" when action in [:create, :update]
  plug :action

  def index(conn, _params) do
    scripts = Repo.all(Script)
    render conn, "index.html", scripts: scripts
  end

  def new(conn, _params) do
    changeset = Script.changeset(%Script{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"script" => script_params}) do
    changeset = Script.changeset(%Script{}, script_params)

    if changeset.valid? do
      Repo.insert(changeset)

      conn
      |> put_flash(:info, "Script created succesfully.")
      |> redirect(to: script_path(conn, :index))
    else
      render conn, "new.html", changeset: changeset
    end
  end

  def show(conn, %{"id" => id}) do
    script = Repo.get(Script, id)
    render conn, "show.html", script: script
  end

  def edit(conn, %{"id" => id}) do
    script = Repo.get(Script, id)
    changeset = Script.changeset(script)
    render conn, "edit.html", script: script, changeset: changeset
  end

  def update(conn, %{"id" => id, "script" => script_params}) do
    script = Repo.get(Script, id)
    changeset = Script.changeset(script, script_params)

    if changeset.valid? do
      Repo.update(changeset)

      conn
      |> put_flash(:info, "Script updated succesfully.")
      |> redirect(to: script_path(conn, :index))
    else
      render conn, "edit.html", script: script, changeset: changeset
    end
  end

  def delete(conn, %{"id" => id}) do
    script = Repo.get(Script, id)
    Repo.delete(script)

    conn
    |> put_flash(:info, "Script deleted succesfully.")
    |> redirect(to: script_path(conn, :index))
  end
end
