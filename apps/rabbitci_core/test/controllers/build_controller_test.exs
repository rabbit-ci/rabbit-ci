defmodule RabbitCICore.BuildControllerTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias RabbitCICore.Repo
  alias RabbitCICore.Build
  alias Ecto.Model

  # TODO: Test bad params
  def generate_records(builds: amount) do
    project = Repo.insert!(%Project{name: "blah", repo: "lala"})
    branch = Repo.insert!(%Branch{name: "branch1", project_id: project.id})
    time = Ecto.DateTime.utc()
    builds = for _ <- 1..amount do
      Model.build(branch, :builds)
      |> Build.changeset(%{start_time: time,
                           finish_time: time,
                           commit: "eccee02ec18a36bcb2615b8c86d401b0618738c2"})
      |> Repo.insert!
    end

    {project, branch, builds}
  end

  test "page offset should default to 0" do
    {project, branch, _} = generate_records(builds: 40)
    response = get("/builds", [project: project.name, branch: branch.name])
    body = Poison.decode!(response.resp_body)
    assert hd(body["data"])["attributes"]["build-number"] == 40
    assert List.last(body["data"])["attributes"]["build-number"] == 11
  end

  test "page offset should work" do
    {project, branch, _} = generate_records(builds: 40)
    response =
      get("/builds", [project: project.name, branch: branch.name,
                      page: %{offset: "1"}])
    body = Poison.decode!(response.resp_body)
    assert hd(body["data"])["attributes"]["build-number"] == 10
    assert List.last(body["data"])["attributes"]["build-number"] == 1
  end

  test "show a single build" do
    {project, branch, [build]} = generate_records(builds: 1)
    url = "/builds/#{build.build_number}"
    response = get(url, [project: project.name, branch: branch.name])
    body = Poison.decode!(response.resp_body)
    assert is_map(body)
  end
end
