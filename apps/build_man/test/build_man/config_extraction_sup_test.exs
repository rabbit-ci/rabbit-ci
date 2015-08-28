defmodule BuildMan.ConfigExtractionSupTest do
  use ExUnit.Case, async: false # Mocks are sync
  import Mock

  @pr_content """
  # example-project
  Example project for Rabbit CI!
  """

  @commit_content """
  # example-project
  Example project for Rabbit CI
  """

  test "Extracting a file from a pr" do
    path = Path.join(__DIR__, "../fixtures/test_repos/example-project.bundle")
    |> Path.expand

    term = :erlang.term_to_binary(%{repo: path,
                                    pr: 1,
                                    file: "README.md",
                                    build_id: -1})
    |> do_test(@pr_content)
  end

  test "Extracting a file from a commit" do
    path = Path.join(__DIR__, "../fixtures/test_repos/example-project.bundle")
    |> Path.expand

    :erlang.term_to_binary(%{repo: path,
                             commit: "3f9c0bdbab553aa565370e6933eea15a85e646d2",
                             file: "README.md",
                             build_id: -1})
    |> do_test(@commit_content)
  end

  @exchange "rabbitci_builds_file_extraction_exchange"

  defp do_test(term, content) do
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)

    pid = self()
    with_mock BuildMan.FileExtraction,
    [reply: fn(_, content, _, _) -> send(pid, {:replied, content}) end,
      finish: fn -> send(pid, :finished) end] do
      AMQP.Basic.publish(chan, @exchange, "", term)

      # We're not using `assert called` here because we need to wait
      # on the process in case it hasn't finished.
      assert_receive {:replied, ^content}, 1000
      assert_receive :finished, 1000
    end
  end
end
