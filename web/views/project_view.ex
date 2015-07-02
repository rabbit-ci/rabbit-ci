defmodule RabbitCICore.ProjectView do
  use RabbitCICore.Web, :view

  def render("index.json", %{conn: conn, projects: projects}) do
    RabbitCICore.ProjectSerializer.format(projects, conn, %{})
  end

  def render("show.json", %{conn: conn, project: project}) do
    RabbitCICore.ProjectSerializer.format(project, conn, %{})
  end
end
