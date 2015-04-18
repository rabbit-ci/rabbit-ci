use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rabbitci, Rabbitci.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :rabbitci, Rabbitci.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "rabbitci_test",
  size: 1,
  max_overflow: false

config :exq,
  host: '127.0.0.1',
  port: 6379,
  namespace: "resque",
  queues: ["nothing"] # We need a queue which will never be written to so that it does not timeout.
               # We can add things to the queue just fine.
