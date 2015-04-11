defmodule Rabbitci.Endpoint do
  use Phoenix.Endpoint, otp_app: :rabbitci

  # Serve at "/" the given assets from "priv/static" directory
  plug Plug.Static,
    at: "/", from: :rabbitci,
    only: ~w(css images js favicon.ico robots.txt)

  plug Plug.Logger

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_rabbitci_key",
    signing_salt: "5yrWD+HO",
    encryption_salt: "frlrKqup"

  plug :router, Rabbitci.Router
end
