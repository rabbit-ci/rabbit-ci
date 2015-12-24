defmodule RabbitCICore.BranchControllerTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Repo
  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias Ecto.Model

  test "Get all branches for project" do
    project = Repo.insert! %Project{name: "project1",
                                    repo: "git@example.com:user/project"}
    for n <- 1..5 do
      Repo.insert! %Branch{name: "branch#{n}", project_id: project.id}
    end

    response = get("/branches", [project: project.name])
    {:ok, body} = response.resp_body |> Poison.decode
    assert response.status == 200
    assert length(body["data"]) == 5
    assert Enum.sort(Map.keys(hd(body["data"])["attributes"])) ==
      Enum.sort(["name", "inserted-at", "updated-at"])
  end

  test "get a single branch" do
    project = Repo.insert! %Project{name: "project1",
                                    repo: "git@example.com:user/project"}

    branch =
      Model.build(project, :branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!

    response = get("/branches/#{branch.name}", [project: project.name])
    {:ok, body} =
      response.resp_body |> Poison.decode

    assert response.status == 200
    assert is_map(body["data"])
    assert body["data"]["attributes"]["name"] == branch.name
    assert body["data"]["relationships"]["builds"]["links"]["related"] ==
      "/builds?branch=branch1&project=project1"
    assert length(body["included"]) == 1
    assert hd(body["included"])["type"] == "projects"
    assert hd(body["included"])["id"] == to_string(project.id)
  end

  test "branch does not exist" do
    project = Repo.insert! %Project{name: "project1",
                                    repo: "git@example.com:user/project"}
    assert_raise Plug.Conn.WrapperError,
    ~r/expected at least one result but got none in query/, fn ->
      get("/branches/fakebranch", [project: project.name])
    end
  end
end
