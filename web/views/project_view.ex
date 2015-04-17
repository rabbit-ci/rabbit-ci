defmodule Rabbitci.ProjectView do
  use Rabbitci.Web, :view

  def render("index.json", conn = %{projects: projects}) do
    Rabbitci.ProjectSerializer.to_map(projects, scope: conn)
  end

  def render("show.json", conn = %{project: project}) do
    # TODO: This does not work. Will fix soon...
    throw "You can find me in project_view.ex. I am broken and need to be fixed."
    thing = %{project: [project]} =
      Rabbitci.ProjectSerializer.to_map([project], [array_root: :project, scope: conn])

    Map.merge(thing, %{project: project})
  end


end
