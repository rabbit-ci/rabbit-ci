defmodule RabbitCICore.BuildTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Repo
  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias RabbitCICore.Build
  alias RabbitCICore.Step
  alias Ecto.Model

  # FIXME: Rewrite this test
  test "build_number must be unique in the scope of branch" do
    p1 =
      Project.changeset(%Project{}, %{name: "project1", repo: "repo123"})
      |> Repo.insert!

    b1 =
      Model.build(p1, :branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!

    b2 =
      Model.build(p1, :branches)
      |> Branch.changeset(%{name: "branch2"})
      |> Repo.insert!

    build1 =
      Model.build(b1, :builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert!

    build2 =
      Model.build(b1, :builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert!

    build3 =
      Model.build(b2, :builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert!

    assert build1.build_number == 1
    assert build2.build_number == 2
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

  defp create_models do
    project =
      Project.changeset(%Project{}, %{name: "project1", repo: "repo123"})
      |> Repo.insert!

    branch =
      Model.build(project, :branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!

    build =
      Model.build(branch, :builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert!

    {project, branch, build}
  end


  test "status/1 for build" do
    {_, _, build} = create_models

    for {status, index} <- Enum.with_index ["queued", "running", "failed"] do
      Model.build(build, :steps)
      |> Step.changeset(%{name: "Step ##{index}", status: status})
      |> Repo.insert!
    end

    assert Build.status(build) == "failed"
  end

  test "status/1 for build with no steps" do
    {_, _, build} = create_models
    assert Build.status(build) == "queued"
  end
end
