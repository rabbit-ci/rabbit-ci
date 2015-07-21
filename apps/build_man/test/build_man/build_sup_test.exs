defmodule BuildMan.BuildSupTest do
  use ExUnit.Case, async: false # Mocks are sync
  import Mock

  test "Extracting a file" do
    path = Path.join(__DIR__, "../fixtures/test_repos/example-project.bundle")
    |> Path.expand
    term = :erlang.term_to_binary(%{repo: path,
                                    pr: 1})
    {:ok, conn} = AMQP.Connection.open("amqp://guest:guest@localhost")
    {:ok, chan} = AMQP.Channel.open(conn)

    pid = self()
    with_mock BuildMan.FileExtraction,
    [reply: fn(_, _) -> send(pid, :replied) end,
      finish: fn -> send(pid, :finished) end] do
      AMQP.Basic.publish(chan, "rabbitci_build_exchange", "", term)

      # We're not using `assert called` here because we need to wait
      # on the process in case it hasn't finished.
      assert_receive :replied, 500
      assert_receive :finished, 500
    end
  end
end
