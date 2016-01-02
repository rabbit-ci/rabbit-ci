defmodule RabbitCICore.BranchTest do
  use RabbitCICore.ModelCase

  alias RabbitCICore.{Branch, Project}

  # Only valid _before_ calling Repo.insert
  @valid_attrs %{name: "my-branch", project_id: -1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Branch.changeset(%Branch{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Branch.changeset(%Branch{}, @invalid_attrs)
    refute changeset.valid?
    assert {:project_id, "can't be blank"} in changeset.errors
    assert {:name, "can't be blank"} in changeset.errors
  end

  test "changeset without project is invalid" do
    changeset = Branch.changeset(%Branch{}, @valid_attrs)
    assert {:error, changeset} = Repo.insert changeset
    refute changeset.valid?
    assert {:project_id, "does not exist"} in changeset.errors
  end

  test "name must be unique in the scope of project" do
    p1 = Repo.insert! Project.changeset(%Project{}, %{name: "project1", repo: "repo123"})

    p1
    |> Ecto.Model.build(:branches)
    |> Branch.changeset(%{name: "branch1"})
    |> Repo.insert!

    assert {:error, b2} =
      p1
      |> Ecto.Model.build(:branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert # Validation happens on insert.

    refute b2.valid?
    assert {:name, "has already been taken"} in b2.errors

    assert {:ok, _} =
      Project.changeset(%Project{}, %{name: "project2", repo: "another_repo"})
      |> Repo.insert!
      |> Ecto.Model.build(:branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert
  end
end
