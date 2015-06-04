defmodule Rabbitci.ProjectView do
  use Rabbitci.Web, :view

  def render("index.json", %{conn: conn, projects: projects}) do
    # project_map = Rabbitci.ProjectSerializer.to_map(projects, scope: conn)
    Rabbitci.ProjectSerializer.as_json(projects, conn, %{})
    # branches = for project <- projects do
    #   case Rabbitci.Project.latest_build(project) do
    #     nil -> nil
    #     a -> a.branch
    #   end
    # end |> Enum.filter(fn(x) -> x != nil end)
    # branch_map = Phoenix.View.render(Rabbitci.BranchView,
    #                                  "index.json", branches: branches)
    # Map.merge(project_map, branch_map)
  end

  def render("show.json", %{conn: conn, project: project}) do
    Rabbitci.ProjectSerializer.as_json(project, conn, %{})
    # thing = %{project: [project]} =
    #   Rabbitci.ProjectSerializer.to_map([projecta], [array_root: :project, scope: conn])

    # project_map = Map.merge(thing, %{project: project})
    # case Rabbitci.Project.latest_build(projecta) do
    #   nil -> project_map
    #   a ->
    #     Phoenix.View.render(Rabbitci.BranchView,
    #                         "index.json", branches: [a.branch])
    #     |> Map.merge(project_map)
    # end
  end
end
