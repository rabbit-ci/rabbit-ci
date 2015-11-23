defmodule RabbitCICore.BuildView do
  use RabbitCICore.Web, :view
  alias RabbitCICore.BuildSerializer

  def render("index.json", %{conn: conn, builds: builds}) do
    BuildSerializer.format(builds, conn, %{})
  end
  def render("show.json", %{conn: conn, build: build}) do
    BuildSerializer.format(build, conn, %{})
  end
  def render("running_builds.json", %{conn: conn, builds: builds}) do
    BuildSerializer.format(builds, conn, %{})
  end
end
