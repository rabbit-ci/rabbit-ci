defmodule RabbitCICore.BuildTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Repo
  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias RabbitCICore.Build
  alias Ecto.Model

  # FIXME: Rewrite this test
  test "build_number must be unique in the scope of branch" do
    p1 =
      Project.changeset(%Project{}, %{name: "project1", repo: "repo123"})
      |> Repo.insert!

    b1 =
      Model.build(p1, :branches, %{name: "branch1"})
      |> Branch.changeset
      |> Repo.insert!

    b2 =
      Model.build(p1, :branches, %{name: "branch2"})
      |> Branch.changeset
      |> Repo.insert!

    build1 =
      Model.build(b1, :builds, %{commit: "xyz"})
      |> Build.changeset
      |> Repo.insert!

    build2 =
      Model.build(b1, :builds, %{commit: "xyz"})
      |> Build.changeset
      |> Repo.insert!

    build3 =
      Model.build(b2, :builds, %{commit: "xyz"})
      |> Build.changeset
      |> Repo.insert!

    assert build1.build_number == 1
    assert build2.build_number == 2
    assert build3.build_number == 1
  end

  test "status" do
    assert Build.status(["queued", "queued", "queued"]) == "queued"
    assert Build.status(["running", "queued", "error"]) == "error"
    assert Build.status(["running", "running", "failed"]) == "failed"
    assert Build.status(["queued", "queued", "finished"]) == "running"
    assert Build.status(["queued", "queued", "running"]) == "running"
    assert Build.status(["finished", "finished", "finished"]) == "finished"
    assert Build.status([]) == "queued"
  end
end
