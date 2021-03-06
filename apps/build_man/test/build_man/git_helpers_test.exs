defmodule BuildMan.BuildHelpersTest do
  use ExUnit.Case
  alias BuildMan.GitHelpers
  alias BuildMan.GitHelpers.GitError
  alias BuildMan.FileHelpers

  test "git/2 should error on bad commands" do
    assert_raise GitError, fn ->
      GitHelpers.git(["non-existent-command"], true)
    end
  end

  test "git/2 should allow setting a path" do
    assert [_] = GitHelpers.git(["rev-parse", "--git-dir"], true)
    assert_raise GitError, fn ->
      GitHelpers.git(["-C", "not-real", "rev-parse", "--git-dir"], true)
    end
  end

  test "clone_repo/3 should clone with repo and commit" do
    {:ok, path} = FileHelpers.unique_folder("rabbit_ci_build_man_test")
    on_exit({:clean_up, path}, fn -> File.rm_rf!(path) end)

    repo = Path.join(__DIR__, "../fixtures/test_repos/example-project.bundle")
    |> Path.expand

    GitHelpers.clone_repo(
      path,
      %{repo: repo, commit: "eccee02ec18a36bcb2615b8c86d401b0618738c2"},
      true
    )

    rev = hd(GitHelpers.git(["rev-parse", "HEAD"], true, [path: path]))
    assert rev == "eccee02ec18a36bcb2615b8c86d401b0618738c2\n"
  end

  test "clone_repo/3 should clone with repo and pr" do
    {:ok, path} = FileHelpers.unique_folder("rabbit_ci_build_man_test")
    on_exit({:clean_up, path}, fn -> File.rm_rf!(path) end)

    repo = Path.join(__DIR__, "../fixtures/test_repos/example-project.bundle")
    |> Path.expand

    GitHelpers.clone_repo(
      path,
      %{repo: repo, pr: 1},
      true
    )

    rev = hd(GitHelpers.git(["rev-parse", "HEAD"], true, [path: path]))
    assert rev == "b78104685141fec938866fd4591bfc0caaee9424\n"
  end
end
