defmodule Rabbitci.BuildView do
  use Rabbitci.Web, :view

  def render("index.json", %{builds: builds}) do
    Rabbitci.BuildSerializer.to_map(builds)
  end

end
