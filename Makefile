default:
	echo Run a task...

.PHONY: default test clean server repl server-prod migrate

test:
	mix test

apps/rabbitci_core/config/prod.secret.exs:
	cp apps/rabbitci_core/config/prod.secret.exs.example apps/rabbitci_core/config/prod.secret.exs

# Test env auto migrates
migrate: apps/rabbitci_core/config/prod.secret.exs
	MIX_ENV=dev mix ecto.create -r RabbitCICore.Repo
	MIX_ENV=dev mix ecto.migrate -r RabbitCICore.Repo
	MIX_ENV=prod mix ecto.create -r RabbitCICore.Repo
	MIX_ENV=prod mix ecto.migrate -r RabbitCICore.Repo

clean:
	mix clean --deps
	mix cmd mix clean --deps

server:
	iex -S mix phoenix.server

server-prod:
	MIX_ENV=prod mix compile
	MIX_ENV=prod PORT=4000 iex -S mix phoenix.server

repl:
	iex -S mix
