defmodule Rabbitci.ProjectView do
  use Rabbitci.Web, :view

  def render("index.json", conn = %{projects: projects}) do
    Rabbitci.ProjectSerializer.to_map(projects, scope: conn)
  end

end
