defmodule Rabbitci.BuildControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Project
  alias Rabbitci.Branch
  alias Rabbitci.Repo

  def generate_a_lot_of_builds do
    project_id = Repo.insert(%Project{name: "blah", repo: "lala"}).id
    branch_id = Repo.insert(%Branch{name: "branch1", project_id: project_id}).id
    time = Ecto.DateTime.utc()
    ids = for n <- 1..40 do
      b = %Rabbitci.Build{build_number: n,
                          start_time: time,
                          finish_time: time,
                          branch_id: branch_id}
      |> Rabbitci.Repo.insert
      b.id
    end

    {project_id, branch_id, ids}
  end

  test "page offset should default to 0" do
    {project_id, branch_id, _} = generate_a_lot_of_builds
    url = "/projects/#{project_id}/branches/#{branch_id}/builds"
    response = get url
    body = Poison.decode!(response.resp_body)
    assert List.last(body["builds"])["build_number"] == 30
  end

  test "page offset should work" do
    {project_id, branch_id, _} = generate_a_lot_of_builds
    url = "/projects/#{project_id}/branches/#{branch_id}/builds"
    response = get url, [page: %{offset: "1"}]
    body = Poison.decode!(response.resp_body)
    assert List.last(body["builds"])["build_number"] == 40
  end

  test "show a single build" do
    {project_id, branch_id, ids} = generate_a_lot_of_builds
    url = "/projects/#{project_id}/branches/#{branch_id}/builds/1"
    response = get url
    body = Poison.decode!(response.resp_body)
    assert Dict.size(body["builds"]) == 1
  end
end
