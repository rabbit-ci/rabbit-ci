defmodule RabbitCICore.ProjectTest do
  use RabbitCICore.ModelCase

  alias RabbitCICore.Project

  @valid_attrs %{name: "project1", repo: "my@repo.git", webhook_secret: "foo"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Project.changeset(%Project{}, @invalid_attrs)
    refute changeset.valid?
    assert {:name, "can't be blank"} in changeset.errors
    assert {:repo, "can't be blank"} in changeset.errors
  end

  test "name must be unique" do
    changeset = Project.changeset(%Project{}, @valid_attrs)
    assert changeset.valid?

    assert {:ok, _} = Repo.insert changeset
    assert {:error, new_changeset} = Repo.insert changeset

    assert {:name, "has already been taken"} in new_changeset.errors
  end

  test "repo must be unique" do
    changeset_valid = Project.changeset(%Project{}, @valid_attrs)
    assert changeset_valid.valid?
    assert {:ok, _} = Repo.insert changeset_valid

    duplicate_repo_attrs = put_in(@valid_attrs.name, "Other name")
    changeset_invalid = Project.changeset(%Project{}, duplicate_repo_attrs)
    assert {:error, changeset_dup_repo} = Repo.insert changeset_invalid
    assert {:repo, "has already been taken"} in changeset_dup_repo.errors
  end
end
