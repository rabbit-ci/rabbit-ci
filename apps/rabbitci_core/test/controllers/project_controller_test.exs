defmodule RabbitCICore.ProjectControllerTest do
  use RabbitCICore.ConnCase

  alias RabbitCICore.Project

  test "index page with no projects", %{conn: conn} do
    conn = get conn, project_path(conn, :index)
    body = json_response(conn, 200)
    assert length(body["data"]) == 0
  end

  test "index page with projects", %{conn: conn} do
    Repo.insert! %Project{name: "project1",
                         repo: "git@example.com:user/project1"}
    Repo.insert! %Project{name: "project2",
                         repo: "git@example.com:user/project2"}

    conn = get conn, project_path(conn, :index)
    body = json_response(conn, 200)
    assert length(body["data"]) == 2
  end

  test "index page for non existing project", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, project_path(conn, :index, "fake", [])
    end
  end

  test "index page for real project", %{conn: conn} do
    project =
      %Project{name: "project1", repo: "git@example.com:user/project1"}
      |> Repo.insert!

    conn = get conn, project_path(conn, :index, [name: project.name])
    body = json_response(conn, 200)
    conn_alt = get conn, project_path(conn, :index, project.name, [])
    body_alt = json_response(conn_alt, 200)

    assert body == body_alt
    resp_project = body["data"]

    assert resp_project["id"] != nil
    assert resp_project["attributes"]["name"] != nil
    assert resp_project["attributes"]["repo"] != nil
    assert is_binary(resp_project["attributes"]["inserted-at"])
    assert is_binary(resp_project["attributes"]["updated-at"])
  end
end
