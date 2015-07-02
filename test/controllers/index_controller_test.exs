defmodule RabbitCICore.IndexControllerTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  test "/ should be 200" do
    assert get("/").status == 200
  end
end
