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

    get "/projects", ProjectController, :index
    get "/projects/:name", ProjectController, :show
    post "/projects/start_build", ProjectController, :start_build

    get "/branches", BranchController, :index
    get "/branches/:branch", BranchController, :show

    get "/logs", LogController, :show

    get "/builds", BuildController, :index
    get "/builds/:build_number", BuildController, :show
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
