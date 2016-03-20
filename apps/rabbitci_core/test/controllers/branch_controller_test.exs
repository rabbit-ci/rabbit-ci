defmodule RabbitCICore.BranchControllerTest do
  use RabbitCICore.ConnCase

  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias Ecto.Model

  test "Get all branches for project", %{conn: conn} do
    project = Repo.insert! %Project{name: "project1",
                                    repo: "git@example.com:user/project"}
    for n <- 1..5 do
      Repo.insert! %Branch{name: "branch#{n}", project_id: project.id}
    end

    conn = get conn, branch_path(conn, :index, [project: project.name])
    body = json_response(conn, 200)
    assert length(body["data"]) == 5

    assert_sort Map.keys(hd(body["data"])["attributes"]) ==
      ["name", "inserted-at", "updated-at"]
  end

  test "get a single branch", %{conn: conn} do
    project = Repo.insert! %Project{name: "project1",
                                    repo: "git@example.com:user/project"}

    branch =
      Model.build(project, :branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!

    conn = get conn, branch_path(conn, :index, [branch: branch.name,
                                                project: project.name])
    body = json_response(conn, 200)

    conn_alt = get conn, branch_path(conn, :index, branch.name,
                                     [project: project.name])
    body_alt = json_response(conn_alt, 200)

    assert body == body_alt

    assert is_map(body["data"])
    assert body["data"]["attributes"]["name"] == branch.name
    assert body["data"]["relationships"]["builds"]["links"]["related"] ==
      build_path(conn, :index, [branch: branch.name, project: project.name])
    assert length(body["included"]) == 1

    types = Enum.flat_map(body["included"], &([&1["type"]]))
    ids = Enum.flat_map(body["included"], &([&1["id"]]))

    assert_sort types == ["projects"]
    assert_sort ids == [to_string project.id]
  end


  test "branch does not exist", %{conn: conn} do
    project = Repo.insert! %Project{name: "project1",
                                    repo: "git@example.com:user/project"}
    assert_raise Ecto.NoResultsError, fn ->
      get conn, branch_path(conn, :index, "fake", [project: project.name])
    end
  end
end
