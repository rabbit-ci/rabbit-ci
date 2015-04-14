use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :rabbitci, Rabbitci.Endpoint,
  secret_key_base: "4mpXTddK2ee1EiNbJjP1l9+IP/hK2T2bGG+LTWkNNILghR5+IHA+wYc/8u0KdO7f"

# Configure your database
config :rabbitci, Rabbitci.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "rabbitci_prod"

config :exq,
  host: '127.0.0.1',
  port: 6379,
  namespace: "resque",
  queues: [""] # We put an empty string for the queue so that it does not attempt to run anything.
               # We can add things to the queue just fine.
