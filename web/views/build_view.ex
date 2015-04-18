defmodule Rabbitci.BuildView do
  use Rabbitci.Web, :view

  def render("index.json", %{builds: builds}) do
    Rabbitci.BuildSerializer.to_map(builds)
  end

  def render("show.json", %{build: build}) do
    Rabbitci.BuildSerializer.to_map(build)
  end

  def render("config_file.json", %{config_file: config_file}) do
    Rabbitci.ConfigFileSerializer.to_map(config_file)
  end

end
