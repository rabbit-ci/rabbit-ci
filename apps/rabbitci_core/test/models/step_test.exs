defmodule RabbitCICore.StepTest do
  use RabbitCICore.ModelCase
  import RabbitCICore.Factory

  alias RabbitCICore.{Project, Branch, Build, Step, Log}

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
    build = create(:build)
    attrs = put_in(@valid_attrs.build_id, build.id)
    changeset = Step.changeset(%Step{}, attrs)
    assert {:ok, model} = Repo.insert changeset
  end

  test "Step.update_status!/2 should update the status of a step" do
    for status <- ["queued", "running", "failed", "finished"] do
      step = create(:step)
      updated_step = Step.update_status!(step.id, status)
      assert updated_step.status == status
    end
  end

  test "Step.log/2 :no_clean" do
    step = create(:step)

    for str <- ~w(foo bar baz) do
      stdio = IO.ANSI.format([:bright, :red, str]) |> to_string
      # Make sure that the string we start with contains ANSI escape codes.
      assert String.contains?(stdio, "\e[31m")
      create(:log, %{stdio: stdio, step: step})
    end

    assert Step.log(step, :no_clean) ==
      "\e[1m\e[31mfoo\e[0m\e[1m\e[31mbar\e[0m\e[1m\e[31mbaz\e[0m"
  end

  test "Step.log/2 :clean" do
    step = create(:step)

    for str <- ~w(foo bar baz) do
      stdio = IO.ANSI.format([:bright, :red, str]) |> to_string
      # Make sure that the string we start with contains ANSI escape codes.
      assert String.contains?(stdio, "\e[31m")
      create(:log, %{stdio: stdio, step: step})
    end

    assert Step.log(step, :clean) == "foobarbaz"
  end
end
