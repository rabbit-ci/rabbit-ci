defmodule RabbitCICore.ProjectView do
  use RabbitCICore.Web, :view

  alias RabbitCICore.ProjectSerializer

  def render("index.json", %{conn: conn, projects: projects}) do
    ProjectSerializer.format(projects, conn, %{})
  end

  def render("show.json", %{conn: conn, project: project}) do
    ProjectSerializer.format(project, conn, %{})
  end
end
