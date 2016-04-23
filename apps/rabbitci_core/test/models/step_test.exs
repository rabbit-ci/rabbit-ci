defmodule RabbitCICore.StepTest do
  use RabbitCICore.ModelCase
  import RabbitCICore.Factory

  alias RabbitCICore.Step

  @valid_attrs %{name: "job1", build_id: -1}
  @invalid_attrs %{}

  test "changeset with invalid attributes" do
    changeset = Step.changeset(%Step{}, @invalid_attrs)
    refute changeset.valid?
    assert {:name, "can't be blank"} in changeset.errors
    assert {:build_id, "can't be blank"} in changeset.errors
  end

  test "changeset without build is invalid" do
    changeset = Step.changeset(%Step{}, @valid_attrs)
    assert {:error, changeset} = Repo.insert changeset
    refute changeset.valid?
    assert {:build_id, "does not exist"} in changeset.errors
  end

  test "changeset with build is valid" do
    build = create(:build)
    attrs = put_in(@valid_attrs.build_id, build.id)
    changeset = Step.changeset(%Step{}, attrs)
    assert {:ok, _model} = Repo.insert changeset
  end
end
