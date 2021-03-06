default:
	echo Run a task...

.PHONY: setup_osx default check clean server repl server-prod migrate

BREW-exists: ; @which brew > /dev/null

setup_osx: BREW-exists
	brew update
	brew install elixir postgresql rabbitmq git
	brew tap caskroom/cask
	brew cask install vagrant virtualbox
	brew services start postgresql
	brew services start rabbitmq
	mix local.hex --force
	mix local.rebar
	mix deps.get

check:
	mix test

config/prod.secret.exs:
	cp config/prod.secret.exs.example config/prod.secret.exs

# Test env auto migrates
migrate: config/prod.secret.exs
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
