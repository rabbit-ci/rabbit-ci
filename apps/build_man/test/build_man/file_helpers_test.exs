defmodule BuildMan.FileHelpersTest do
  use ExUnit.Case
  alias BuildMan.FileHelpers

  test "unique_folder/1 should give me a unique folder" do
    {:ok, path} = FileHelpers.unique_folder("rabbit_ci_build_man_test")
    {:ok, path2} = FileHelpers.unique_folder("rabbit_ci_build_man_test")
    on_exit({:clean_up, path}, fn -> File.rm_rf!(path) end)
    on_exit({:clean_up, path2}, fn -> File.rm_rf!(path2) end)

    assert path != path2
  end
end
