defmodule Rabbitci.BuildControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Project
  alias Rabbitci.Branch
  alias Rabbitci.Repo

  def generate_a_lot_of_builds do
    project = Repo.insert(%Project{name: "blah", repo: "lala"})
    branch = Repo.insert(%Branch{name: "branch1", project_id: project.id})
    time = Ecto.DateTime.utc()
    ids = for n <- 1..40 do
      b = %Rabbitci.Build{build_number: n,
                          start_time: time,
                          finish_time: time,
                          branch_id: branch.id}
      |> Rabbitci.Repo.insert
      b.id
    end

    {project.name, branch.name, ids}
  end

  test "page offset should default to 0" do
    {project_name, branch_name, _} = generate_a_lot_of_builds
    url = "/projects/#{project_name}/branches/#{branch_name}/builds"
    response = get url
    body = Poison.decode!(response.resp_body)
    assert hd(body["builds"])["build_number"] == 40
  end

  test "page offset should work" do
    {project_name, branch_name, _} = generate_a_lot_of_builds
    url = "/projects/#{project_name}/branches/#{branch_name}/builds"
    response = get url, [page: %{offset: "1"}]
    body = Poison.decode!(response.resp_body)
    assert hd(body["builds"])["build_number"] == 10
  end

  test "show a single build" do
    {project_name, branch_name, ids} = generate_a_lot_of_builds
    url = "/projects/#{project_name}/branches/#{branch_name}/builds/1"
    response = get url
    body = Poison.decode!(response.resp_body)
    assert is_map(body)
  end
end
