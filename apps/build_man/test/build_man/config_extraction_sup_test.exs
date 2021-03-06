defmodule BuildMan.ConfigExtractionSupTest do
  use RabbitCICore.ModelCase, async: false
  alias RabbitCICore.Project
  alias RabbitCICore.Branch
  alias RabbitCICore.Build
  alias RabbitCICore.Repo

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

    {_, _, build} = create_models
    :erlang.term_to_binary(%{repo: path,
                             pr: 1,
                             file: "README.md",
                             build_id: build.id})
    |> do_test(@pr_content)
  end

  test "Extracting a file from a commit" do
    path = Path.join(__DIR__, "../fixtures/test_repos/example-project.bundle")
    |> Path.expand

    {_, _, build} = create_models
    :erlang.term_to_binary(%{repo: path,
                             commit: "3f9c0bdbab553aa565370e6933eea15a85e646d2",
                             file: "README.md",
                             build_id: build.id})
    |> do_test(@commit_content)
  end

  @exchange Application.get_env(:build_man, :config_extraction_exchange)

  defp create_models do
    project =
      Project.changeset(%Project{}, %{name: "a/project1", repo: "repo123"})
      |> Repo.insert!

    branch =
      Ecto.build_assoc(project, :branches)
      |> Branch.changeset(%{name: "branch1"})
      |> Repo.insert!

    build =
      Ecto.build_assoc(branch, :builds)
      |> Build.changeset(%{commit: "xyz"})
      |> Repo.insert!

    {project, branch, build}
  end

  defp do_test(term, content) do
    Application.put_env(:build_man, :config_extraction_processor_pid, self)
    {:ok, conn} = AMQP.Connection.open
    {:ok, chan} = AMQP.Channel.open(conn)
    AMQP.Basic.publish(chan, @exchange, "", term)

    # We're not using `assert called` here because we need to wait
    # on the process in case it hasn't finished.
    assert_receive {:replied, ^content}, 1000
    assert_receive :finished, 1000
  end
end
