defmodule Rabbitci.BranchSerializerTest do
  use Rabbitci.TestHelper
  use Rabbitci.Integration.Case

  test "Correct attributes should exist" do
    b = Rabbitci.Repo.insert(%Rabbitci.Branch{name: "thing"})
    map = Rabbitci.BranchSerializer.to_list(b)

    assert map.id != nil
    assert is_binary(map.updated_at)
    assert is_binary(map.inserted_at)
    assert name != nil
    assert is_list(map.builds_ids)

    assert Enum.sort(Map.keys(map)) == Enum.sort([:id, :updated_at, :name,
                                                  :build_ids])
  end
end
