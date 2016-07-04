defmodule RabbitCICore.BuildTest do
  use RabbitCICore.ModelCase, async: true
  import RabbitCICore.Factory

  alias RabbitCICore.{Project, Branch, Build}

  # Only valid _before_ calling Repo.insert.
  @valid_attrs %{commit: "abc", branch_id: -1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Build.changeset(%Build{}, @valid_attrs)
    assert changeset.data.config_extracted == "false"
    assert changeset.valid?
  end

  test "changeset with valid config_extracted" do
    for config_extracted <- ["true", "false", "error"] do
      attrs = %{commit: "abc", branch_id: -1, config_extracted: config_extracted}
      changeset = Build.changeset(%Build{}, attrs)
      assert Ecto.Changeset.get_field(changeset, :config_extracted) == config_extracted
      assert changeset.valid?
    end
  end

  test "changeset with invalid config_extracted" do
    for config_extracted <- ["bacon", "turtles", "sandwich"] do
      attrs = %{commit: "abc", branch_id: -1, config_extracted: config_extracted}
      changeset = Build.changeset(%Build{}, attrs)
      refute changeset.valid?
      assert {:config_extracted, {"is invalid", []}} in changeset.errors
    end
  end

  test "changeset with invalid attributes" do
    changeset = Build.changeset(%Build{}, @invalid_attrs)
    refute changeset.valid?
    assert {:branch_id, {"can't be blank", []}} in changeset.errors
    assert {:commit, {"can't be blank", []}} in changeset.errors
    assert changeset.data.config_extracted == "false"
  end

  test "changeset without branch is invalid" do
    changeset = Build.changeset(%Build{}, @valid_attrs)
    assert {:error, changeset} = Repo.insert changeset
    refute changeset.valid?
    assert {:branch_id, {"does not exist", []}} in changeset.errors
  end

  test "changeset with branch is valid" do
    assert {:ok, _model} =
      Project.changeset(%Project{}, %{name: "a/project1", repo: "repo123"})
      |> Repo.insert!
      |> Ecto.build_assoc(:branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!
      |> Ecto.build_assoc(:builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert
  end

  test "build_number is incremented in the scope of a branch" do
    p1 =
      Project.changeset(%Project{}, %{name: "a/project1", repo: "repo123"})
      |> Repo.insert!

    b1 =
      Ecto.build_assoc(p1, :branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!

    b2 =
      Ecto.build_assoc(p1, :branches)
      |> Branch.changeset(%{name: "branch2"})
      |> Repo.insert!

    build1 =
      Ecto.build_assoc(b1, :builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert!

    build2 =
      Ecto.build_assoc(b1, :builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert!

    build3 =
      Ecto.build_assoc(b2, :builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert!

    assert build1.build_number == 1
    assert build2.build_number == 2
    assert build3.build_number == 1
  end

  test "build_number must be unique in the scope of branch" do
    p1 =
      Project.changeset(%Project{}, %{name: "a/project1", repo: "repo123"})
      |> Repo.insert!

    b1 =
      Ecto.build_assoc(p1, :branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!

    b2 =
      Ecto.build_assoc(p1, :branches)
      |> Branch.changeset(%{name: "branch2"})
      |> Repo.insert!

    build1 =
      Ecto.build_assoc(b1, :builds)
      |> Build.changeset(%{commit: "xyz", build_number: 1})
      |> Repo.insert!

    assert {:error, build2} =
      Ecto.build_assoc(b1, :builds)
      |> Build.changeset(%{commit: "xyz", build_number: 1})
      |> Repo.insert

    assert {:build_number, {"has already been taken", []}} in build2.errors

    build3 =
      Ecto.build_assoc(b2, :builds)
      |> Build.changeset(%{commit: "xyz", build_number: 1})
      |> Repo.insert!

    assert build1.build_number == 1
    assert build3.build_number == 1
  end

  test "status/1 when is_list" do
    assert Build.status(["queued", "queued", "queued"]) == "queued"
    assert Build.status(["running", "queued", "error"]) == "error"
    assert Build.status(["running", "running", "failed"]) == "failed"
    assert Build.status(["queued", "queued", "finished"]) == "running"
    assert Build.status(["queued", "queued", "running"]) == "running"
    assert Build.status(["finished", "finished", "finished"]) == "finished"
    assert Build.status([]) == "queued"
  end

  test "status/1 for build" do
    build = insert(:build)
    step = insert(:step, build: build)

    for status <- ["queued", "running", "failed"] do
      insert(:job, step: step, status: status)
    end

    assert Build.status(build) == "failed"
  end

  test "status/1 for build with no jobs" do
    build = insert(:build)

    assert Build.status(build) == "queued"
  end
end
