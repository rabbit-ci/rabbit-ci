defmodule RabbitCICore.ProjectControllerTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Repo
  alias RabbitCICore.Project

  test "index page with no projects" do
    response = get("/projects")
    body = Poison.decode!(response.resp_body)
    assert length(body["data"]) == 0
    assert response.status == 200
  end

  test "index page with projects" do
    Repo.insert! %Project{name: "project1",
                         repo: "git@example.com:user/project1"}
    Repo.insert! %Project{name: "project2",
                         repo: "git@example.com:user/project2"}
    response = get("/projects")
    body = Poison.decode!(response.resp_body)
    assert length(body["data"]) == 2
    assert response.status == 200
  end

  test "show page for non existing project" do
    response = get("/projects/fakeproject")
    assert response.status == 404
  end

  test "show page for real project" do
    Repo.insert! %Project{name: "project1",
                         repo: "git@example.com:user/project1"}
    response = get("/projects/project1")
    body = Poison.decode!(response.resp_body)
    assert response.status == 200
    assert is_map(body["data"])

    project = body["data"]
    assert project["id"] != nil
    assert project["attributes"]["name"] != nil
    assert project["attributes"]["repo"] != nil
    assert is_binary(project["attributes"]["inserted-at"])
    assert is_binary(project["attributes"]["updated-at"])
  end
end
