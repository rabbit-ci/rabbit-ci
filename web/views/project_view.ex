defmodule Rabbitci.ProjectView do
  use Rabbitci.Web, :view

  def render("index.json", %{conn: conn, projects: projects}) do
    Rabbitci.ProjectSerializer.as_json(projects, conn, %{})
  end

  def render("show.json", %{conn: conn, project: project}) do
    Rabbitci.ProjectSerializer.as_json(project, conn, %{})
  end
end
