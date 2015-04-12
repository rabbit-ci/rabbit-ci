defmodule Rabbitci.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use Rabbitci.Web, :controller
      use Rabbitci.Web, :view

  Keep the definitions in this module short and clean,
  mostly focused on imports, uses and aliases.
  """

  def view do
    quote do
      use Phoenix.View, root: "web/templates"

      # Import URL helpers from the router
      import Rabbitci.Router.Helpers
    end
  end

  def controller do
    quote do
      use Phoenix.Controller

      # Alias the data repository as a convenience
      alias Rabbitci.Repo

      import Rabbitci.ControllerHelpers
      # Import URL helpers from the router
      import Rabbitci.Router.Helpers
    end
  end

  def model do
    quote do
      use Ecto.Model
      import Rabbitci.ModelHelpers
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
