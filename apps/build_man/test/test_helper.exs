# Tests tagged `:external` are disabled because they depend on an external
# service. Anything not running on the developer's machine is considered
# external. You can run these tests with: `mix test --only external:true`
ExUnit.configure(exclude: [external: true])
ExUnit.start
Ecto.Adapters.SQL.Sandbox.mode(RabbitCICore.Repo, :manual)
Application.ensure_all_started(:ex_machina)
