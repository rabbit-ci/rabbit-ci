use Mix.Config

config :rabbitci_core, :log_saver_limit, 5

config :build_man, :worker_limit, 2
config :build_man, :config_extraction_limit, 2
config :build_man, :log_streamer_limit, 10

config :build_man, :processed_logs_exchange, "rabbitci.processed_logs"
config :build_man, :build_logs_exchange, "rabbitci.build_logs"
config :build_man, :build_exchange, "rabbitci.builds"
config :build_man, :build_queue, "rabbitci.builds"
config :build_man, :config_extraction_exchange, "rabbitci.config_extraction"
config :build_man, :config_extraction_queue, "rabbitci.config_extraction"
