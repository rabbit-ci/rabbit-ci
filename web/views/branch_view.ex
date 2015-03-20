defmodule Rabbitci.BranchView do
  use Rabbitci.Web, :view

  def render("index.json", %{branches: branches}) do
    Rabbitci.BranchSerializer.to_map(branches)
  end

end
