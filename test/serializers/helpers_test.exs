defmodule Rabbitci.HelpersTest do
  use Rabbitci.TestHelper

  defmodule TestStruct do
    defstruct a_time: nil
  end

  defmodule TestSerializer do
    require Rabbitci.SerializerHelpers
    alias Rabbitci.SerializerHelpers
    SerializerHelpers.time(a_time, TestStruct)
  end

  test "time macro" do
    assert TestSerializer.a_time(%TestStruct{}) == nil
    curtime = Ecto.DateTime.utc()
    assert TestSerializer.a_time(%TestStruct{a_time: curtime}) ==
      Ecto.DateTime.to_string(curtime)
  end
end
