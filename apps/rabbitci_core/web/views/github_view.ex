defmodule RabbitCICore.GitHubView do
  use RabbitCICore.Web, :view

  alias RabbitCICore.BuildView

  def render("create.json", %{conn: conn, build: build}) do
    BuildView.format(build, conn, %{})
  end
end
