use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :rabbitci_core, RabbitCICore.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  cache_static_lookup: false,
  code_reloader: true,
  watchers: []

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :rabbitci_core, RabbitCICore.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "rabbitci_dev",
  size: 10

config :exq,
  host: '127.0.0.1',
  port: 6379,
  namespace: "resque",
  queues: ["nothing"] # Empty queue so that we do not timeout.
               # We can add things to the queue just fine.
