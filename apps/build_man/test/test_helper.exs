# Tests tagged `:external` are disabled because they depend on an external
# service. Anything not running on the developer's machine is considered
# external. You can run these tests with: `mix test --only external:true`
IO.puts "Creating DB and running migrations"
Mix.Task.run "ecto.create", ["-r", "RabbitCICore.Repo"]
Mix.Task.run "ecto.migrate", ["-r", "RabbitCICore.Repo"]
ExUnit.configure(exclude: [external: true])
ExUnit.start

defmodule BuildMan.Integration.Case do
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL
  alias RabbitCICore.Repo

  setup_all do
    SQL.begin_test_transaction(Repo, [])
    on_exit fn -> SQL.rollback_test_transaction(Repo, []) end
    :ok
  end

  setup do
    SQL.restart_test_transaction(Repo, [])
    :ok
  end
end
