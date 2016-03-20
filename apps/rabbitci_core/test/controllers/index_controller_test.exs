defmodule RabbitCICore.IndexControllerTest do
  use RabbitCICore.ConnCase

  test "/ should be 200", %{conn: conn} do
    conn = get conn, index_path(conn, :index)
    assert text_response(conn, 200)
  end
end
