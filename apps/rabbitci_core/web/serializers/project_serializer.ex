defmodule RabbitCICore.ProjectSerializer do
  use JaSerializer
  alias RabbitCICore.Router.Helpers, as: RouterHelpers

  attributes [:name, :repo, :inserted_at, :updated_at]
  has_many :branches , link: :branches_link

  def type, do: "projects"

  def branches_link(record, conn) do
    RouterHelpers.branch_path(conn, :index, %{project: record.name})
  end
end
