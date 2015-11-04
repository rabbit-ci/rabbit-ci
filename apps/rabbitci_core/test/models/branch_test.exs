defmodule RabbitCICore.BranchTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Repo
  alias RabbitCICore.Project
  alias RabbitCICore.Branch

  test "name must be unique in the scope of project" do
    p1 =
      Project.changeset(%Project{}, %{name: "project1", repo: "repo123"})
      |> Repo.insert!

    p2 =
      Project.changeset(%Project{}, %{name: "project2", repo: "another_repo"})
      |> Repo.insert!

    Branch.changeset(%Branch{}, %{name: "branch1", project_id: p1.id})
    |> Repo.insert!

    assert {:error, b2} =
      Branch.changeset(%Branch{}, %{name: "branch1", project_id: p1.id})
      |> Repo.insert # Validation happens on insert.

    refute b2.valid?

    assert {:ok, _} =
      Branch.changeset(%Branch{}, %{name: "branch1", project_id: p2.id})
      |> Repo.insert
  end
end
