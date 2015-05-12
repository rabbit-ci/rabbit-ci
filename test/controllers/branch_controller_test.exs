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

    {:ok, response} = get("/projects/#{project.name}/branches").resp_body
    |> Poison.decode
    assert length(response["branches"]) == 5
    assert Enum.sort(Map.keys(hd(response["branches"]))) ==
      Enum.sort(["id", "name", "inserted_at", "updated_at"])
  end
end
