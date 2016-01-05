defmodule RabbitCICore.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use RabbitCICore.Web, :controller
      use RabbitCICore.Web, :view

  Keep the definitions in this module short and clean,
  mostly focused on imports, uses and aliases.
  """

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import URL helpers from the router
      import RabbitCICore.Router.Helpers
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      # Alias the data repository as a convenience
      alias RabbitCICore.Repo

      # Import URL helpers from the router
      import RabbitCICore.Router.Helpers
    end
  end

  def model do
    quote do
      use Ecto.Model
      use Ecto.Model.Callbacks
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      alias RabbitCICore.Repo
      import Ecto
      import Ecto.Query, only: [from: 1, from: 2]
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
