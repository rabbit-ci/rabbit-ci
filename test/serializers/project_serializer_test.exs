defmodule Rabbitci.ProjectSerializerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  test "Correct attributes should exist" do
    p = Rabbitci.Repo.insert(%Rabbitci.Project{name: "Project", repo: "things"})
    map = Rabbitci.ProjectSerializer.to_map(p)
    assert map.id != nil
    assert map.name != nil
    assert map.repo != nil
    assert is_list(map.branch_ids)
    assert map.branch_url != nil
    assert is_binary(map.inserted_at)
    assert is_binary(map.updated_at)

    assert Enum.sort(Map.keys(map)) == Enum.sort([:id, :name, :repo,
                                                  :branch_ids, :branch_url,
                                                  :inserted_at, :updated_at])
  end
end
