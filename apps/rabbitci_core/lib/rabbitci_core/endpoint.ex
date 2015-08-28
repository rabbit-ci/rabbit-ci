defmodule RabbitCICore.Endpoint do
  use Phoenix.Endpoint, otp_app: :rabbitci_core

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
    key: "_rabbitci_core_key",
    signing_salt: "5yrWD+HO",
    encryption_salt: "frlrKqup"

  plug RabbitCICore.Router
end
