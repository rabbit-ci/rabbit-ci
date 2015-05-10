defmodule Rabbitci.BuildTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Repo
  alias Rabbitci.Project
  alias Rabbitci.Branch
  alias Rabbitci.Build

  test "build_number must be unique in the scope of branch" do
    p1 = Project.changeset(%Project{}, %{name: "project1", repo: "repo123"})
    |> Repo.insert
    b1 = Branch.changeset(%Branch{}, %{name: "branch1", project_id: p1.id,
                                       exists_in_git: false})
    |> Repo.insert

    b2 = Branch.changeset(%Branch{}, %{name: "branch2", project_id: p1.id,
                                       exists_in_git: false})
    |> Repo.insert

    build = Repo.insert Build.changeset(%Build{}, %{build_number: 1,
                                                    branch_id: b1.id,
                                                    commit: "xyz"})
    assert !Build.changeset(%Build{}, %{build_number: 1,
                                        branch_id: b1.id,
                                        commit: "xyz"}).valid?

    assert Build.changeset(%Build{}, %{build_number: 1,
                                       branch_id: b2.id,
                                       commit: "xyz"}).valid?
  end
end
