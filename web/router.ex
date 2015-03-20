defmodule Rabbitci.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Rabbitci do
    pipe_through :api # Use the default browser stack

    # get "/", PageController, :index

    resources "/projects", ProjectController, except: [:new, :edit]

    get "/projects/:project_id/branches", BranchController, :index

    #resources "/branches", BranchController, except: [:new, :edit]
    resources "/builds", BuildController, except: [:new, :edit]
  end

  # Other scopes may use custom stacks.
  # scope "/api", Rabbitci do
  #   pipe_through :api
  # end
end
