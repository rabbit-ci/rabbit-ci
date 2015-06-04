defmodule Rabbitci.BuildControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Project
  alias Rabbitci.Branch
  alias Rabbitci.Repo
  alias Rabbitci.ConfigFile
  alias Rabbitci.Script
  alias Rabbitci.Log
  # TODO: Test bad params
  def generate_records(builds: amount) do
    project = Repo.insert(%Project{name: "blah", repo: "lala"})
    branch = Repo.insert(%Branch{name: "branch1", project_id: project.id})
    time = Ecto.DateTime.utc()
    builds = for n <- 1..amount do
      %Rabbitci.Build{build_number: n,
                      start_time: time,
                      finish_time: time,
                      branch_id: branch.id,
                      commit: "eccee02ec18a36bcb2615b8c86d401b0618738c2"}
      |> Rabbitci.Repo.insert
    end

    {project, branch, builds}
  end

  test "page offset should default to 0" do
    {project, branch, _} = generate_records(builds: 40)
    url = "/projects/#{project.name}/branches/#{branch.name}/builds"
    response = get(url)
    body = Poison.decode!(response.resp_body)
    assert hd(body["builds"])["buildNumber"] == 40
    assert List.last(body["builds"])["buildNumber"] == 11
  end

  test "page offset should work" do
    {project, branch, _} = generate_records(builds: 40)
    url = "/projects/#{project.name}/branches/#{branch.name}/builds"
    response = get(url, [page: %{offset: "1"}])
    body = Poison.decode!(response.resp_body)
    assert hd(body["builds"])["buildNumber"] == 10
    assert List.last(body["builds"])["buildNumber"] == 1
  end

  test "show a single build" do
    {project, branch, _} = generate_records(builds: 1)
    url = "/projects/#{project.name}/branches/#{branch.name}/builds/1"
    response = get(url)
    body = Poison.decode!(response.resp_body)
    assert is_map(body)
  end

  test "get config file" do
    config = %{"ENV" => %{"VAR1" => "VAR1 Global"},
               "scripts" => [%{"ENV" => %{"SOMETHING" => "Just a variable"},
                               "name" => "main"},
                             %{"ENV" => %{"VAR1" => "Override global var"},
                               "name" => "override-VAR1"}]}
    |> Poison.encode!

    expected =
      %{"scripts" =>
         [%{"ENV" =>
             %{"RABBIT_CI_BRANCH" => "branch1",
               "RABBIT_CI_BUILD_NUMBER" => 1,
               "RABBIT_CI_COMMIT" => "eccee02ec18a36bcb2615b8c86d401b0618738c2",
               "RABBIT_CI_PROJECT_NAME" => "blah", "RABBIT_CI_REPO" => "lala",
               "SOMETHING" => "Just a variable", "VAR1" => "VAR1 Global"},
            "name" => "main"},
          %{"ENV" =>
             %{"RABBIT_CI_BRANCH" => "branch1", "RABBIT_CI_BUILD_NUMBER" => 1,
               "RABBIT_CI_COMMIT" => "eccee02ec18a36bcb2615b8c86d401b0618738c2",
               "RABBIT_CI_PROJECT_NAME" => "blah", "RABBIT_CI_REPO" => "lala",
               "VAR1" => "Override global var"}, "name" => "override-VAR1"}]}

    {project, branch, builds} = generate_records(builds: 1)
    build = hd(builds)
    Repo.insert(%ConfigFile{build_id: build.id, raw_body: config})
    url = ("/projects/#{project.name}/branches/#{branch.name}/builds/" <>
      "#{build.build_number}/config")
    response = get(url)
    assert Poison.decode!(response.resp_body) == expected
  end

  test "requesting a log" do
    {project, branch, builds} = generate_records(builds: 1)
    build = hd(builds)
    url = ("/projects/#{project.name}/branches/#{branch.name}/builds/" <>
      "#{build.build_number}/log")

    logs = [{"main", "This is log 'main'"},
            {"secondary", "This is log 'secondary'"}]
    for {name, log} <- logs do
      script = Repo.insert %Script{name: name, status: "running",
                                   build_id: build.id}
      Repo.insert(%Log{stdio: log, script_id: script.id})
    end

    response = get(url)
    body = response.resp_body
    for {_, log} <- logs do
      assert String.contains?(body, log)
    end
  end

  test "uploading logs" do
    {project, branch, builds} = generate_records(builds: 1)
    build = hd(builds)
    url = ("/projects/#{project.name}/branches/#{branch.name}/builds/" <>
      "#{build.build_number}/log")
    resp = put(url, %{"log_string" => "This is log 'main'", "script" => "main"})
    assert resp.status == 200

    resp = get(url)
    assert String.contains?(resp.resp_body, "This is log 'main'")

    resp = put(url, %{"log_string" => "This should append to main",
                      "script" => "main"})
    assert resp.status == 200
    resp = get(url)
    assert String.contains?(resp.resp_body, "This is log 'main'")
    assert String.contains?(resp.resp_body, "This should append to main")

    resp = put(url, %{"log_string" => "This is a new script",
                      "script" => "secondary"})
    assert resp.status == 200
    resp = get(url)
    assert String.contains?(resp.resp_body, "This is log 'main'")
    assert String.contains?(resp.resp_body, "This should append to main")
    assert String.contains?(resp.resp_body, "This is a new script")
  end
end
