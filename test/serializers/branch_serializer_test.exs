defmodule Rabbitci.BranchSerializerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  test "Correct attributes should exist" do
    p = Rabbitci.Repo.insert(%Rabbitci.Project{name: "Project", repo: "things"})
    b = Rabbitci.Repo.insert(%Rabbitci.Branch{name: "thing", project_id: p.id})
    map = Rabbitci.BranchSerializer.to_map(b)

    assert map.id != nil
    assert is_binary(map.updated_at)
    assert is_binary(map.inserted_at)
    assert map.name != nil
    assert is_list(map.build_ids)
    assert map.build_url != nil

    assert Enum.sort(Map.keys(map)) == Enum.sort([:id, :updated_at, :name,
                                                  :build_ids, :build_url,
                                                  :inserted_at])
  end
end
