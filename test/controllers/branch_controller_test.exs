defmodule Rabbitci.BranchControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Repo
  alias Rabbitci.Project
  alias Rabbitci.Branch

  test "Get all branches for project" do
    project = Repo.insert %Project{name: "project1",
                                   repo: "git@example.com:user/project"}
    for n <- 1..5 do
      Repo.insert %Branch{name: "branch#{n}", exists_in_git: false,
                          project_id: project.id}
    end

    response = get("/projects/#{project.name}/branches")
    {:ok, body} = response.resp_body |> Poison.decode
    assert response.status == 200
    assert length(body["branches"]) == 5
    assert Enum.sort(Map.keys(hd(body["branches"]))) ==
      Enum.sort(["id", "name", "inserted_at", "updated_at"])
  end

  test "get a single branch" do
    project = Repo.insert %Project{name: "project1",
                                   repo: "git@example.com:user/project"}
    branch = Repo.insert %Branch{name: "branch1", exists_in_git: false,
                                 project_id: project.id}

    response = get("/projects/#{project.name}/branches/#{branch.name}")
    {:ok, body} =
      response.resp_body |> Poison.decode

    assert response.status == 200
    assert length(body["branches"]) == 1
    assert hd(body["branches"])["name"] == branch.name
  end

  test "branch does not exist" do
    project = Repo.insert %Project{name: "project1",
                                   repo: "git@example.com:user/project"}
    response = get("/projects/#{project.name}/branches/fakebranch")
    assert response.status == 404
  end
end
