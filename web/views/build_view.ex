defmodule Rabbitci.BuildView do
  use Rabbitci.Web, :view

  def render("index.json", %{builds: builds}) do
    # IO.puts inspect builds
    # %{something: 3}
    Rabbitci.BuildSerializer.to_map(builds)
  end

end
