defmodule RabbitCICore.IndexView do
  use RabbitCICore.Web, :view
  alias RabbitCICore.BuildSerializer

  def render("running_builds.json", %{conn: conn, builds: builds}) do
    BuildSerializer.format(builds, conn, %{})
  end
end
