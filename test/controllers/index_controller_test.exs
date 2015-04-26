defmodule Rabbitci.IndexControllerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  test "/ should be 200" do
    assert get("/").status == 200
  end
end
