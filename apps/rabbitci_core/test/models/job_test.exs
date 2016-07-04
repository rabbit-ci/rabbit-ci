defmodule RabbitCICore.JobTest do
  use RabbitCICore.ModelCase, async: true
  import RabbitCICore.Factory

  alias RabbitCICore.Job

  @valid_attrs %{status: "queued", step_id: -1}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Job.changeset(%Job{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Job.changeset(%Job{}, @invalid_attrs)
    refute changeset.valid?
    assert {:status, {"can't be blank", []}} in changeset.errors
  end

  test "changeset with valid status" do
    for status <- ["queued", "running", "failed", "finished", "error"] do
      attrs = %{@valid_attrs | status: status}
      changeset = Job.changeset(%Job{}, attrs)
      assert Ecto.Changeset.get_field(changeset, :status) == status
      assert changeset.valid?
    end
  end

  test "changeset with invalid status" do
    for status <- ["bacon", "turtles", "sandwich"] do
      attrs = %{@valid_attrs | status: status}
      changeset = Job.changeset(%Job{}, attrs)
      refute changeset.valid?
      assert {:status, {"is invalid", []}} in changeset.errors
    end
  end

  test "changeset without step is invalid" do
    changeset = Job.changeset(%Job{}, @valid_attrs)
    assert {:error, changeset} = Repo.insert changeset
    refute changeset.valid?
    assert {:step_id, {"does not exist", []}} in changeset.errors
  end

  test "changeset with step is valid" do
    step = insert(:step)
    attrs = put_in(@valid_attrs.step_id, step.id)
    changeset = Job.changeset(%Job{}, attrs)
    assert {:ok, _model} = Repo.insert changeset
  end

  test "Job.update_status!/2 should update the status of a job" do
    for status <- ["queued", "running", "failed", "finished", "error"] do
      job = insert(:job)
      updated_job = Job.update_status!(job.id, status)
      assert updated_job.status == status
    end
  end

  test "Job.log/1" do
    job = insert(:job)

    for str <- ~w(foo bar) do
      insert(:log, %{stdio: str, job: job, fg: "red", style: "bright"})
    end

    assert Job.log(job) ==
      "<span class='ansi red bright'>foo</span><span class='ansi red bright'>bar</span>"
  end
end
