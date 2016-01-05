defmodule RabbitCICore.SSHKeyTest do
  use RabbitCICore.ModelCase

  alias RabbitCICore.{SSHKey, Project}

  # Make sure the DB allows strings longer than 255 chars.
  @long_string String.duplicate("a", 2048)
  # Only valid _before_ calling Repo.insert.
  @valid_attrs %{private_key: @long_string, project_id: -1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SSHKey.changeset(%SSHKey{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SSHKey.changeset(%SSHKey{}, @invalid_attrs)
    refute changeset.valid?
    assert {:private_key, "can't be blank"} in changeset.errors
    assert {:project_id, "can't be blank"} in changeset.errors
  end

  test "changeset without project is invalid" do
    changeset = SSHKey.changeset(%SSHKey{}, @valid_attrs)
    assert {:error, changeset} = Repo.insert changeset
    refute changeset.valid?
    assert {:project_id, "does not exist"} in changeset.errors
  end

  test "changeset with project is valid" do
    project =
      %Project{name: "Project", repo: "git@example.com:my/repo.git"}
      |> Repo.insert!

    attrs = put_in(@valid_attrs.project_id, project.id)
    changeset = SSHKey.changeset(%SSHKey{}, attrs)
    assert {:ok, _model} = Repo.insert changeset
  end
end
