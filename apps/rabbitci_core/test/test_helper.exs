ExUnit.start
IO.puts "Creating DB and running migrations"
Mix.Task.run "ecto.create", ["-r", "RabbitCICore.Repo"]
Mix.Task.run "ecto.migrate", ["-r", "RabbitCICore.Repo"]

defmodule RabbitCICore.TestHelper do
  import Plug.Test

  defmacro __using__(_) do
    quote do
      import RabbitCICore.TestHelper
      use Plug.Test
      use ExUnit.Case, async: true
    end
  end

  def post(url, params \\ []), do: _conn(:post, url, params)
  def get(url, params \\ []), do: _conn(:get, url, params)
  def put(url, params \\ []), do: _conn(:put, url, params)

  defp _conn(type, url, params) do
    conn(type, url, params)
    |> Plug.Conn.put_resp_content_type("application/json")
    |> RabbitCICore.Router.call(RabbitCICore.Router.init([]))
  end
end

defmodule RabbitCICore.Integration.Case do
  use ExUnit.CaseTemplate

  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(RabbitCICore.Repo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(RabbitCICore.Repo,
                                                              []) end
    :ok
  end

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(RabbitCICore.Repo, [])
    :ok
  end
end
