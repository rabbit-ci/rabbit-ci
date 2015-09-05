defmodule RabbitCICore.Router do
  use Phoenix.Router
  require IEx
  pipeline :api do
    plug :allow_origin
    plug :accepts, ["json", "json-api"]
  end

  scope "/", RabbitCICore do
    pipe_through :api

    get "/", IndexController, :index

    resources "/projects", ProjectController, except: [:new, :edit]
    post "/projects/start_build", ProjectController, :start_build

    get "/projects/:project_name/branches", BranchController, :index
    get "/projects/:project_name/branches/:name", BranchController, :show

    get "/logs", LogController, :show

    get "/projects/:project_name/branches/:branch_name/builds",
    BuildController, :index
    get "/projects/:project_name/branches/:branch_name/builds/:build_number",
    BuildController, :show
    get "/projects/:project_name/branches/:branch_name/builds/:build_number/config",
    BuildController, :config
  end

  # This should be changed in production and must be based off of the server's
  # configuration.
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
