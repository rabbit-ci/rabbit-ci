defmodule Rabbitci.BuildControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  test "Build should require params" do
    response = get "/builds"
    assert response.status == 400

    body = Poison.decode!(response.resp_body)
    assert body["message"] != nil
    assert body["status"] != nil
  end

  test "page offset should default to 0" do
    time = Ecto.DateTime.utc()
    ids = for n <- 1..110 do
      %Rabbitci.Build{build_number: n,
                      start_time: time,
                      finish_time: time}
      |> Rabbitci.Repo.insert
    end

    response = get "/builds", ids: Enum.to_list(ids)

    body = Poison.decode!(response.resp_body)

    assert List.last(body)["build_number"] == 100
  end
end
