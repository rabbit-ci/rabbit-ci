ExUnit.start

defmodule Rabbitci.TestHelper do
  import Plug.Test

  defmacro __using__(_) do
    quote do
      import Rabbitci.TestHelper
      use Plug.Test
      use ExUnit.Case, async: true
    end
  end

  def post(url, params \\ []), do: _conn(:post, url, params)
  def get(url, params \\ []), do: _conn(:get, url, params)

  defp _conn(type, url, params) do
    conn(type, url, params)
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Rabbitci.Router.call(Rabbitci.Router.init([]))
  end
end

defmodule Rabbitci.Integration.Case do
  use ExUnit.CaseTemplate

  setup_all do
    Ecto.Adapters.SQL.begin_test_transaction(Rabbitci.Repo, [])
    on_exit fn -> Ecto.Adapters.SQL.rollback_test_transaction(Rabbitci.Repo, []) end
    :ok
  end

  setup do
    Ecto.Adapters.SQL.restart_test_transaction(Rabbitci.Repo, [])
    :ok
  end
end
