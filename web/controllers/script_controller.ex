defmodule Rabbitci.ScriptController do
  use Rabbitci.Web, :controller

  alias Rabbitci.Script

  plug :scrub_params, "script" when action in [:create, :update]
  plug :action

  def index(conn, _params) do
    scripts = Repo.all(Script)
    # TODO do something
  end

  def new(conn, _params) do
    changeset = Script.changeset(%Script{})
    # TODO do something
  end

  def create(conn, %{"script" => script_params}) do
    changeset = Script.changeset(%Script{}, script_params)

    if changeset.valid? do
      Repo.insert(changeset)
      # TODO do something else
    else
      # TODO do something
    end
  end

  def show(conn, %{"id" => id}) do
    script = Repo.get(Script, id)
    # TODO do something
  end

  def edit(conn, %{"id" => id}) do
    script = Repo.get(Script, id)
    changeset = Script.changeset(script)
    # TODO do someting
  end

  def update(conn, %{"id" => id, "script" => script_params}) do
    script = Repo.get(Script, id)
    changeset = Script.changeset(script, script_params)

    if changeset.valid? do
      Repo.update(changeset)
      # TODO do something
    else
      # TODO do something
    end
  end

  def delete(conn, %{"id" => id}) do
    script = Repo.get(Script, id)
    Repo.delete(script)
    # TODO do something
  end
end
