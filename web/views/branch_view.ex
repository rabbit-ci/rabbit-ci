defmodule Rabbitci.BranchView do
  use Rabbitci.Web, :view

  def render("index.json", %{branches: branches}) do
    branch_map = Rabbitci.BranchSerializer.to_map(branches)

    builds = for branch <- branches do
      latest = Rabbitci.Branch.latest(branch)
    end

    builds = Enum.filter(builds, fn(x) -> x != nil end)
    if builds != nil do
      Rabbitci.BuildSerializer.to_map(builds)
      |> Map.merge(branch_map)
    else
      branch_map
    end
    # branch_map <> builds_map
  end

end
