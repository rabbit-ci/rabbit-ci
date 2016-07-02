defmodule RabbitMQ.ConnTest do
  use ExUnit.Case, async: true
  alias RabbitMQ.Conn

  @moduletag :rabbitmq_integration

  setup do
    {:ok, conn} = Conn.start_link([])
    {:ok, conn: conn}
  end

  test "Conn will provide a connection", %{conn: conn} do
    assert {:ok, %AMQP.Connection{}} = GenServer.call(conn, :conn)
  end

  test "Conn will reconnect when connection goes down", %{conn: conn} do
    assert {:ok, %AMQP.Connection{pid: pid}} = GenServer.call(conn, :conn)
    :ok = GenServer.stop(pid)
    refute match? {:ok, %AMQP.Connection{pid: ^pid}}, GenServer.call(conn, :conn)
  end

  test "Conn will close connection on kill", %{conn: conn} do
    assert {:ok, %AMQP.Connection{pid: pid}} = GenServer.call(conn, :conn)
    :ok = GenServer.stop(conn)
    refute Process.alive?(pid)
  end
end
