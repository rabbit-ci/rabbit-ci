defmodule Rabbitci.BuildView do
  use Rabbitci.Web, :view

  def render("index.json", %{builds: builds}) do
    Rabbitci.BuildSerializer.to_map(builds)
  end

  def render("show.json", %{build: build}) do
    Rabbitci.BuildSerializer.to_map(build)
  end

end
