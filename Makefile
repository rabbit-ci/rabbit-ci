default:
	echo Run a task...

.PHONY: default test clean server repl server-prod migrate

test:
	mix test

# Test env auto migrates
migrate:
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
