defmodule Rabbitci.SerializerHelpersTest do
  use ExUnit.Case
  import Rabbitci.SerializerHelpers

  time(start_time, Rabbitci.Build)

  test "macro should be created correctly" do
    assert start_time(%Rabbitci.Build{}) == nil
  end

  test "macro var 2 should work" do
    curtime = Ecto.DateTime.utc()
    assert start_time(%Rabbitci.Build{start_time: curtime}) ==
      Ecto.DateTime.to_string(curtime)
  end
end
