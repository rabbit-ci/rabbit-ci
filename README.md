# RabbitCI

This is RabbitCI.

RabbitCI is a Continuous Integration server. It is currently in pre-alpha
stage. It would help if you would write some code. Look at the issues page for
things to do.

## Dependencies
The backend depends on:

- Elixir
- Erlang
- Postgres (username: postgres, password: postgres, databases:
  rabbitci_test, rabbitci_dev)
- RabbitMQ
- Vagrant

All other dependencies should be installed by running `mix cmd mix
deps.get, compile` in the project root.
