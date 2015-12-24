# Tests tagged `:external` are disabled because they depend on an external
# service. Anything not running on the developer's machine is considered
# external. You can run these tests with: `mix test --only external:true`
ExUnit.configure(exclude: [external: true])
ExUnit.start
IO.puts "Creating DB and running migrations"
Mix.Task.run "ecto.create", ["-r", "RabbitCICore.Repo"]
Mix.Task.run "ecto.migrate", ["-r", "RabbitCICore.Repo"]
Ecto.Adapters.SQL.rollback_test_transaction(RabbitCICore.Repo)
Ecto.Adapters.SQL.begin_test_transaction(RabbitCICore.Repo)

defmodule BuildMan.Integration.Case do
  use ExUnit.CaseTemplate

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(RabbitCICore.Repo, [])
    end
    :ok
  end
end
