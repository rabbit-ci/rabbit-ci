use Mix.Config

config :build_man, :build_logs_exchange, "rabbitci.build_logs.test"
config :build_man, :build_exchange, "rabbitci.builds.test"
config :build_man, :build_queue, "rabbitci.builds.test"
config :build_man, :config_extraction_exchange, "rabbitci.config_extraction.test"
config :rabbitci_core, :config_extraction_exchange, "rabbitci.config_extraction.test"
config :build_man, :config_extraction_queue, "rabbitci.config_extraction.test"

config :logger, level: :warn
