defmodule RabbitCICore.Router do
  use Phoenix.Router

  pipeline :api do
    plug :accepts, ["json"]
    plug JaSerializer.Deserializer
  end

  scope "/", RabbitCICore do
    pipe_through :api

    get "/", IndexController, :index

    scope "/projects" do
      get "/", ProjectController, :index
      get "/:name", ProjectController, :index
      delete "/:id", ProjectController, :delete
      post "/", ProjectController, :create
    end

    scope "/branches" do
      get "/", BranchController, :index
      get "/:branch", BranchController, :index
    end

    get "/logs", LogController, :show

    scope "/builds" do
      get "/", BuildController, :index
      get "/running_builds", BuildController, :running_builds
      post "/start_build", BuildController, :start_build

      # This is a catch all. Make sure it comes last!
      get "/:build_number", BuildController, :index
    end

    post "/github", GitHubController, :create
  end
end
