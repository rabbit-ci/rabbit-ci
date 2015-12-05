# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for third-
# party users, it should be done in your mix.exs file.

# Sample configuration:
#
config :logger, :console,
format: "\n$time $metadata[$level] $levelpad$message"

config :build_man, :worker_limit, 2
config :build_man, :config_extraction_limit, 2
config :build_man, :log_streamer_limit, 10

config :build_man, :build_logs_exchange, "rabbitci.build_logs"
config :build_man, :build_logs_queue, "rabbitci.build_logs"
config :build_man, :build_exchange, "rabbitci.builds"
config :build_man, :build_queue, "rabbitci.builds"
config :build_man, :config_extraction_exchange, "rabbitci.config_extraction"
config :rabbitci_core, :config_extraction_exchange, "rabbitci.config_extraction"
config :build_man, :config_extraction_queue, "rabbitci.config_extraction"

import_config "../../rabbitci_core/config/config.exs"
import_config "#{Mix.env}.exs"
