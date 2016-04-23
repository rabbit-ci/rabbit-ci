defmodule RabbitCICore.LogTest do
  use RabbitCICore.ModelCase
  import RabbitCICore.Factory

  alias RabbitCICore.Log

  # Only valid _before_ calling Repo.insert
  @valid_attrs %{stdio: "abc", order: 0, type: "stdout", job_id: -1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Log.changeset(%Log{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Log.changeset(%Log{}, @invalid_attrs)
    refute changeset.valid?
    assert {:job_id, "can't be blank"} in changeset.errors
    assert {:stdio, "can't be blank"} in changeset.errors
    assert {:order, "can't be blank"} in changeset.errors
    assert {:type, "can't be blank"} in changeset.errors
  end

  test "changeset with invalid type attribute" do
    changeset = Log.changeset(%Log{}, %{type: "blarg"})
    refute changeset.valid?
    assert {:type, "is invalid"} in changeset.errors
  end

  test "changeset with valid type attribute" do
    for type <- ["stdout", "stderr"] do
      changeset = Log.changeset(%Log{}, put_in(@valid_attrs.type, type))
      assert changeset.valid?
    end
  end

  test "changeset without job is invalid" do
    changeset = Log.changeset(%Log{}, @valid_attrs)
    assert {:error, changeset} = Repo.insert changeset
    refute changeset.valid?
    assert {:job_id, "does not exist"} in changeset.errors
  end

  test "changeset with job is valid" do
    job = create(:job)
    attrs = put_in(@valid_attrs.job_id, job.id)
    changeset = Log.changeset(%Log{}, attrs)
    assert {:ok, _model} = Repo.insert changeset
  end
end
