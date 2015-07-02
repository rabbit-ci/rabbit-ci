defmodule RabbitCICore.BranchView do
  use RabbitCICore.Web, :view

  def render("index.json", %{conn: conn, branches: branches}) do
    RabbitCICore.BranchSerializer.format(branches, conn, %{})
  end

  def render("show.json", %{conn: conn, branch: branch}) do
    RabbitCICore.BranchSerializer.format(branch, conn, %{})
  end
end
