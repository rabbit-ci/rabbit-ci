# Tests tagged `:external` are disabled because they depend on an external
# service. Anything not running on the developer's machine is considered
# external. You can run these tests with: `mix test --only external:true`
ExUnit.configure(exclude: [external: true])
ExUnit.start
IO.puts "Creating DB and running migrations"
Mix.Task.run "ecto.create", ["-r", "RabbitCICore.EctoRepo"]
Mix.Task.run "ecto.migrate", ["-r", "RabbitCICore.EctoRepo"]
Ecto.Adapters.SQL.rollback_test_transaction(RabbitCICore.EctoRepo)
Ecto.Adapters.SQL.begin_test_transaction(RabbitCICore.EctoRepo)
Application.ensure_all_started(:ex_machina)
