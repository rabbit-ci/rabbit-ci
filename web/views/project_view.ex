defmodule Rabbitci.ProjectView do
  use Rabbitci.Web, :view

  def render("index.json", conn = %{projects: projects}) do
    Rabbitci.ProjectSerializer.to_map(projects, scope: conn)
  end

  def render("show.json", conn = %{project: project}) do
    Rabbitci.ProjectSerializer.to_map(project, scope: conn)
  end


end
