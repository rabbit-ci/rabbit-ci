defmodule Rabbitci.ProjectView do
  use Rabbitci.Web, :view

  def render("index.json", conn = %{projects: projects}) do
    Rabbitci.ProjectSerializer.to_map(projects, scope: conn)
  end

  # TODO: This feels really weird.
  def render("show.json", conn = %{project: project}) do
    thing = %{project: [project]} =
      Rabbitci.ProjectSerializer.to_map([project], [array_root: :project, scope: conn])

    Map.merge(thing, %{project: project})
  end
end
