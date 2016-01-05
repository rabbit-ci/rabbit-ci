defmodule RabbitCICore.StepTest do
  use RabbitCICore.ModelCase

  alias RabbitCICore.{Project, Branch, Build, Step}

  @valid_attrs %{name: "step1", status: "queued", build_id: -1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Step.changeset(%Step{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Step.changeset(%Step{}, @invalid_attrs)
    refute changeset.valid?
    assert {:name, "can't be blank"} in changeset.errors
    assert {:status, "can't be blank"} in changeset.errors
    assert {:build_id, "can't be blank"} in changeset.errors
  end

  test "changeset with valid status" do
    for status <- ["queued", "running", "failed", "finished"] do
      attrs = %{name: "step1", status: "queued", build_id: -1, status: status}
      changeset = Step.changeset(%Step{}, attrs)
      assert Ecto.Changeset.get_field(changeset, :status) == status
      assert changeset.valid?
    end
  end

  test "changeset with invalid status" do
    for status <- ["bacon", "turtles", "sandwich"] do
      attrs = %{name: "step1", status: "queued", build_id: -1, status: status}
      changeset = Step.changeset(%Step{}, attrs)
      refute changeset.valid?
      assert {:status, "is invalid"} in changeset.errors
    end
  end

  test "changeset without build is invalid" do
    changeset = Step.changeset(%Step{}, @valid_attrs)
    assert {:error, changeset} = Repo.insert changeset
    refute changeset.valid?
    assert {:build_id, "does not exist"} in changeset.errors
  end

  test "changeset with step is valid" do
    build =
      %Project{name: "Project", repo: "git@example.com:my/repo.git"}
      |> Repo.insert!
      |> Ecto.Model.build(:branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!
      |> Ecto.Model.build(:builds)
      |> Build.changeset(%{commit: "abc"})
      |> Repo.insert!

    attrs = put_in(@valid_attrs.build_id, build.id)
    changeset = Step.changeset(%Step{}, attrs)
    assert {:ok, model} = Repo.insert changeset
  end
end
