defmodule Rabbitci.ProjectSerializerTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper
  alias Rabbitci.ProjectSerializer

  test "Correct attributes should exist" do
    p = Rabbitci.Repo.insert(%Rabbitci.Project{name: "Project", repo: "things"})
    map = ProjectSerializer.to_map(p, scope: %{conn: conn(:get, "jskd", %{})})
    assert map.id != nil
    assert map.name != nil
    assert map.repo != nil
    assert is_binary(map.inserted_at)
    assert is_binary(map.updated_at)
    assert is_map(map.links)

    assert Enum.sort(Map.keys(map)) == Enum.sort([:id, :name, :repo, :links,
                                                  :inserted_at, :updated_at])
  end
end
