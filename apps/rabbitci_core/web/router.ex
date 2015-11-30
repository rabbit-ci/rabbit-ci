defmodule RabbitCICore.Router do
  use Phoenix.Router

  pipeline :api do
    plug :allow_origin
    plug :accepts, ["json"]
  end

  scope "/", RabbitCICore do
    pipe_through :api

    get "/", IndexController, :index

    scope "projects" do
      get "/", ProjectController, :index
      get "/:name", ProjectController, :show
    end

    scope "/branches" do
      get "/", BranchController, :index
      get "/:branch", BranchController, :show
    end

    get "/logs", LogController, :show

    scope "/builds" do
      get "/", BuildController, :index
      get "/running_builds", BuildController, :running_builds
      post "/start_build", BuildController, :start_build

      # This is a catch all. Make sure it comes last!
      get "/:build_number", BuildController, :show
    end

    post "/github", GitHubController, :create
  end

  # This should be changed in production.
  defp allow_origin(conn, _opts) do
    headers = get_req_header(conn, "access-control-request-headers")
    |> Enum.join(", ")

    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-headers", headers)
    |> put_resp_header("access-control-allow-methods", "GET, POST, OPTIONS")
    |> put_resp_header("access-control-max-age", "3600")
  end
end
