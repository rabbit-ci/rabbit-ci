defmodule RabbitCICore.SSHKeyTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.SSHKey

  @valid_attrs %{private_key: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SSHKey.changeset(%SSHKey{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SSHKey.changeset(%SSHKey{}, @invalid_attrs)
    refute changeset.valid?
  end
end
