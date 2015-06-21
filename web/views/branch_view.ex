defmodule Rabbitci.BranchView do
  use Rabbitci.Web, :view

  def render("index.json", %{conn: conn, branches: branches}) do
    Rabbitci.BranchSerializer.format(branches, conn, %{})
  end

  def render("show.json", %{conn: conn, branch: branch}) do
    Rabbitci.BranchSerializer.format(branch, conn, %{})
  end
end
