defmodule RabbitCICore.GitHubView do
  use RabbitCICore.Web, :view

  alias RabbitCICore.BuildSerializer

  def render("create.json", %{conn: conn, build: build}) do
    BuildSerializer.format(build, conn, %{})
  end
end
