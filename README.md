# RabbitCI Backend

This is (most of) the backend for RabbitCI. See
http://github.com/rabbit-ci/rabbit-ci to learn what RabbitCI is.

## Dependencies
The backend depends on:

- Elixir
- Erlang
- Postgres (username: postgres, password: postgres, databases:
  rabbitci_test, rabbitci_dev)
- Redis

All other dependencies should be installed by running `mix cmd mix
deps.get, compile` in the project root.
