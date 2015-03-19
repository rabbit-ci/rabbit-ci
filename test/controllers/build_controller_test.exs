defmodule Rabbitci.BuildControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  def generate_a_lot_of_builds do
    time = Ecto.DateTime.utc()
    for n <- 1..40 do
      b = %Rabbitci.Build{build_number: n,
                      start_time: time,
                      finish_time: time}
      |> Rabbitci.Repo.insert
      b.id
    end
  end

  test "Build should require params" do
    response = get "/builds"
    assert response.status == 400

    body = Poison.decode!(response.resp_body)
    assert body["message"] != nil
    assert body["status"] != nil
  end

  test "page offset should default to 0" do
    ids = generate_a_lot_of_builds
    response = get "/builds", ids: Enum.to_list(ids)
    body = Poison.decode!(response.resp_body)
    assert List.last(body)["build_number"] == 30
  end

  test "page offset should work" do
    ids = generate_a_lot_of_builds
    response = get "/builds", [ids: Enum.to_list(ids), page: %{offset: "1"}]
    body = Poison.decode!(response.resp_body)
    assert List.last(body)["build_number"] == 40
  end
end
