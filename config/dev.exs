use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :rabbitci, Rabbitci.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  cache_static_lookup: false,
  watchers: []

# Watch static and templates for browser reloading.
# *Note*: Be careful with wildcards. Larger projects
# will use higher CPU in dev as the number of files
# grow. Adjust as necessary.
config :rabbitci, Rabbitci.Endpoint, code_reloader: true

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Configure your database
config :rabbitci, Rabbitci.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "rabbitci_dev"

config :exq,
  host: '127.0.0.1',
  port: 6379,
  namespace: "resque",
  queues: ["nothing"] # Empty queue so that we do not timeout.
               # We can add things to the queue just fine.
