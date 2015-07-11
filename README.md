# RabbitCI Backend

This is (most of) the backend for RabbitCI. See
http://github.com/rabbitci/rabbitci to learn what RabbitCI is.

## Dependencies
The backend depends on:

- Elixir
- Erlang
- Postgres (username: postgres, password: postgres, databases:
  rabbitci_test, rabbitci_dev)

All other dependencies should be installed by running `mix cmd mix
deps.get, compile` in the project root.
