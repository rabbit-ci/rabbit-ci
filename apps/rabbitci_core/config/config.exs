# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :rabbitci_core, :app_namespace, RabbitCICore

# Configures the endpoint
config :rabbitci_core, RabbitCICore.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "MOd1xikwYz0y3kr5GlBxA4pDUf5catrgRfANogH5PaCp4QcaJXKpnvorZLq6j6DH",
  debug_errors: false,
  root: Path.expand("..", __DIR__),
  pubsub: [name: RabbitCICore.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :plug, :mimes, %{
  "application/vnd.api+json" => ["json-api"]
}

import_config "../../../config/rabbitmq.exs"
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
