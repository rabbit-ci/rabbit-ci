defmodule Rabibtci.HelpersTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Repo
  alias Rabbitci.Project
  alias Rabbitci.Branch
  alias Rabbitci.Build
  alias Rabbitci.ControllerHelpers

  test "get_build should provide correct build" do
    time = Ecto.DateTime.utc()
    project = Repo.insert!(%Project{name: "blah", repo: "lala"})
    branch1 = Repo.insert!(%Branch{name: "branch1", project_id: project.id})
    build1 = Repo.insert!(%Build{branch_id: branch1.id, build_number: 1,
                       start_time: time, finish_time: time})

    branch2 = Repo.insert!(%Branch{name: "branch2", project_id: project.id})
    build2 = Repo.insert!(%Build{branch_id: branch2.id, build_number: 1,
                                start_time: time, finish_time: time})
    build3 = Repo.insert!(%Build{branch_id: branch2.id, build_number: 2,
                                start_time: time, finish_time: time})

    assert ControllerHelpers.get_build(branch1, "latest") == build1
    assert ControllerHelpers.get_build(branch2, 1) == build2
    assert ControllerHelpers.get_build(branch2, "latest") == build3
  end

  test "get_project_from_repo" do
    project = Repo.insert!(%Project{name: "blah", repo: "lala"})
    assert ControllerHelpers.get_project_from_repo(project.repo) == project
  end

  test "get_branch" do
    project = Repo.insert!(%Project{name: "blah", repo: "lala"})
    branch = Repo.insert!(%Branch{project_id: project.id, name: "branch1"})
    assert ControllerHelpers.get_branch(project, branch.name) == branch
  end
end
