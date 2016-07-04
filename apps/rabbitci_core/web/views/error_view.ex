defmodule RabbitCICore.ErrorView do
  use RabbitCICore.Web, :view

  def render("404.json-api", _assigns) do
    %{message: "Not found"}
  end

  def render("400.json-api", _assigns) do
    %{message: "Bad request"}
  end

  def render("500.json-api", _assigns) do
    %{message: "Internal server error"}
  end
end
