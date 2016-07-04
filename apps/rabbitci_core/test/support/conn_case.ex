defmodule RabbitCICore.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.
  Such tests rely on `Phoenix.ConnTest` and also
  imports other functionality to make it easier
  to build and query models.
  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      alias RabbitCICore.Repo
      import Ecto.Model
      import Ecto.Query, only: [from: 2]
      import RabbitCICore.Router.Helpers

      # The default endpoint for testing
      @endpoint RabbitCICore.Endpoint

      # Sorts left and right before asserting.
      defmacro assert_sort({op, meta, [left, right]}) do
        quote do
          left = Enum.sort(unquote(left))
          right = Enum.sort(unquote(right))
          assert unquote(op)(left, right)
        end
      end
    end
  end

  setup tags do
    unless tags[:async] do
      Ecto.Adapters.SQL.restart_test_transaction(RabbitCICore.EctoRepo, [])
    end

    conn =
      Phoenix.ConnTest.build_conn()
      |> Plug.Conn.put_req_header("accept", "application/vnd.api+json")
      |> Plug.Conn.put_req_header("content-type", "application/vnd.api+json")

    {:ok, conn: conn}
  end
end
