defmodule RabbitCICore.BuildControllerTest do
  use RabbitCICore.ConnCase, async: true

  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias RabbitCICore.Build

  # TODO: Test bad params
  def generate_records(builds: amount) do
    project = Repo.insert!(%Project{name: "blah", repo: "blah"})
    branch = Repo.insert!(%Branch{name: "branch1", project_id: project.id})
    time = Ecto.DateTime.utc()
    builds = for _ <- 1..amount do
      Ecto.build_assoc(branch, :builds)
      |> Build.changeset(%{start_time: time,
                           finish_time: time,
                           commit: "eccee02ec18a36bcb2615b8c86d401b0618738c2"})
      |> Repo.insert!
    end

    {project, branch, builds}
  end

  test "page offset should default to 0", %{conn: conn} do
    {project, branch, _} = generate_records(builds: 40)
    conn = get conn, build_path(conn, :index, [project: project.name,
                                               branch: branch.name])
    body = json_response(conn, 200)
    assert hd(body["data"])["attributes"]["build-number"] == 40
    assert List.last(body["data"])["attributes"]["build-number"] == 11
  end

  test "page offset should work", %{conn: conn} do
    {project, branch, _} = generate_records(builds: 40)
    conn = get conn, build_path(conn, :index, [project: project.name,
                                               branch: branch.name,
                                               page: %{offset: "1"}])
    body = json_response(conn, 200)
    assert hd(body["data"])["attributes"]["build-number"] == 10
    assert List.last(body["data"])["attributes"]["build-number"] == 1
  end

  test "show a single build", %{conn: conn} do
    {project, branch, [build]} = generate_records(builds: 1)
    conn = get conn, build_path(conn, :index,
                                [project: project.name,
                                 branch: branch.name,
                                 build_number: build.build_number])
    body = json_response(conn, 200)

    conn_alt = get conn, build_path(conn, :index, build.build_number,
                                    [project: project.name,
                                     branch: branch.name])
    body_alt = json_response(conn_alt, 200)
    assert body == body_alt
    assert is_map(body)
  end
end
