defmodule Rabbitci.ProjectControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Repo
  alias Rabbitci.Project

  test "index page with no projects" do
    response = get("/projects")
    body = Poison.decode!(response.resp_body)
    assert length(body["projects"]) == 0
    assert response.status == 200
  end

  test "index page with projects" do
    Repo.insert %Project{name: "project1",
                         repo: "git@example.com:user/project1"}
    Repo.insert %Project{name: "project2",
                         repo: "git@example.com:user/project2"}
    response = get("/projects")
    body = Poison.decode!(response.resp_body)
    assert length(body["projects"]) == 2
    assert response.status == 200
  end

  test "show page for non existing project" do
    response = get("/projects/fakeproject")
    assert response.status == 404
  end

  test "show page for real project" do
    Repo.insert %Project{name: "project1",
                         repo: "git@example.com:user/project1"}
    response = get("/projects/project1")
    body = Poison.decode!(response.resp_body)
    assert response.status == 200
    assert body["project"] != nil
  end
end
