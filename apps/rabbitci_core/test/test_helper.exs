ExUnit.start
IO.puts "Creating DB and running migrations"
Mix.Task.run "ecto.create", ["-r", "RabbitCICore.EctoRepo"]
Mix.Task.run "ecto.migrate", ["-r", "RabbitCICore.EctoRepo"]
Ecto.Adapters.SQL.rollback_test_transaction(RabbitCICore.EctoRepo)
Ecto.Adapters.SQL.begin_test_transaction(RabbitCICore.EctoRepo)
Application.ensure_all_started(:ex_machina)
