use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :rabbitci_core, RabbitCICore.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :rabbitci_core, RabbitCICore.EctoRepo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "rabbitci_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  size: 1
