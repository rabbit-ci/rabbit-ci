defmodule Rabbitci.ConfigExtractionControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper
  use ExUnit.Case, async: false

  import Mock

  alias Rabbitci.Repo
  alias Rabbitci.Project
  alias Rabbitci.Branch
  alias Rabbitci.Build

  setup do
    project = Repo.insert %Project{name: "project",
                                   repo: "git@example.com:user/project.git"}
    branch = Repo.insert %Branch{name: "master",
                                 project_id: project.id,
                                 exists_in_git: false}
    build = Repo.insert %Build{build_number: 1, commit: "xyz",
                               branch_id: branch.id}
    {:ok, project: project, branch: branch, build: build}
  end


  test "Missing params" do
    response = post("/config_extraction")
    assert response.status == 400
  end

  test "Bad JSON format", context do
    %{project: project, branch: branch, build: build} = context
    response = post("/config_extraction", %{"repo" => project.repo,
                                           "commit" => build.commit,
                                           "branch" => branch.name,
                                           "build_number" => build.build_number,
                                           "config_string" => "{"})
    assert response.status == 400
  end

  test "Missing 'scripts' map", context do
    %{project: project, branch: branch, build: build} = context
    response = post("/config_extraction", %{"repo" => project.repo,
                                           "commit" => build.commit,
                                           "branch" => branch.name,
                                           "build_number" => build.build_number,
                                           "config_string" => "{}"})
    assert response.status == 400
  end

  test "build does not exist", context do
    %{project: project, branch: branch, build: build} = context
    Repo.delete(build)
    with_mock Exq, [enqueue: fn(_, _, _, _) -> nil end] do
      response = post("/config_extraction",
                      %{"repo" => project.repo,
                        "commit" => build.commit,
                        "branch" => branch.name,
                        "build_number" => build.build_number,
                        "config_string" => ~s({
                                "scripts": [
                                  {
                                      "name": "main"
                                  }
                                ]
                            })})
      assert response.status == 400
      assert !(called Exq.enqueue(:_, :_, :_, :_))
    end
  end

  test "config is nil", context do
    %{project: project, branch: branch, build: build} = context
    build_number = build.build_number
    Repo.delete(build)
    with_mock Exq, [enqueue: fn(_, _, _, _) -> nil end] do
      response = post("/config_extraction",
                      %{"repo" => project.repo,
                        "commit" => build.commit,
                        "branch" => branch.name,
                        "build_number" => build.build_number,
                        "config_string" => nil})
      assert response.status == 400
      assert !(called Exq.enqueue(:_, :_, :_, :_))
    end
  end

  test "Valid config", context do
    %{project: project, branch: branch, build: build} = context
    with_mock Exq, [enqueue: fn(_, _, _, _) -> nil end] do
      assert Repo.preload(build, :config_file).config_file == nil
      response = post("/config_extraction",
                      %{"repo" => project.repo,
                        "commit" => build.commit,
                        "branch" => branch.name,
                        "build_number" => build.build_number,
                        "config_string" => ~s({
                                "scripts": [
                                  {
                                      "name": "main"
                                  }
                                ]
                            })})
      assert response.status == 200
      assert Repo.preload(build, :config_file).config_file != nil
      assert called Exq.enqueue(:exq, "workers", "BuildRunner", :_)
    end
  end
end
