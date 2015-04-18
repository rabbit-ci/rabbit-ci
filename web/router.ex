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
    plug :allow_origin
  end

  scope "/", Rabbitci do
    pipe_through :api

    get "/", PageController, :index

    post "/queue", QueueController, :create
    post "/config_extraction", ConfigExtractionController, :create

    resources "/projects", ProjectController, except: [:new, :edit]

    get "/projects/:project_name/branches", BranchController, :index
    get "/projects/:project_name/branches/:name", BranchController, :show

    get "/projects/:project_name/branches/:branch_name/builds",
    BuildController, :index
    get "/projects/:project_name/branches/:branch_name/builds/:build_number",
    BuildController, :show
    get "/projects/:project_name/branches/:branch_name/builds/:build_number/config_file",
    BuildController, :config_file
  end

  # This should be changed in production and must be based off of the server's
  # configuration.
  defp allow_origin(conn, _opts) do
    headers = get_req_header(conn, "access-control-request-headers")
    |> Enum.join(", ")

    conn
    |> put_resp_header("access-control-allow-origin", "*")
    |> put_resp_header("access-control-allow-headers", headers)
    |> put_resp_header("access-control-allow-methods", "get, post, options")
    |> put_resp_header("access-control-max-age", "3600")
  end
end
