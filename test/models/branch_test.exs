defmodule Rabbitci.BranchTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Repo
  alias Rabbitci.Project
  alias Rabbitci.Branch

  test "name must be unique in the scope of project" do
    p1 = Project.changeset(%Project{}, %{name: "project1", repo: "repo123"})
    |> Repo.insert
    p2 = Project.changeset(%Project{}, %{name: "project2", repo: "another_repo"})
    |> Repo.insert
    b1 = Branch.changeset(%Branch{}, %{name: "branch1", project_id: p1.id,
                                       exists_in_git: false}) |> Repo.insert

    b2 = Branch.changeset(%Branch{}, %{name: "branch1", project_id: p1.id,
                                       exists_in_git: false})
    assert !b2.valid?

    b3 = Branch.changeset(%Branch{}, %{name: "branch1", project_id: p2.id,
                                       exists_in_git: false})
    assert b3.valid?
  end
end
