defmodule BuildMan.GitHelpers do
  defmodule GitError, do: defexception message: "Git errored!"
  require Logger

  def clone_repo(_, _, should_run \\ true)
  def clone_repo(path, %{repo: repo, commit: commit}, should_run) do
    clone = git(["clone", repo, path], should_run)

    cmds = [["checkout", "-qf", commit],
            ["rev-parse", "HEAD"]]

    [clone | for cmd <- cmds, do: git(cmd, [path: path], should_run)]
  end
  def clone_repo(path, %{repo: repo, pr: pr}, should_run) do
    clone = git(["clone", repo, path], should_run)

    cmds = [["fetch", "origin", "+refs/pull/#{pr}/merge:pr/#{pr}"],
            ["checkout", "-qf", "pr/#{pr}"],
            ["rev-parse", "HEAD"]]

    [clone | for cmd <- cmds, do: git(cmd, [path: path], should_run)]
  end

  def git(args, [path: path], should_run) when is_list(args) do
    git(["-C", path] ++ args, should_run)
  end

  def git(args, true) when is_list(args) do
    git_cmd = System.find_executable("git")

    case ExExec.run([git_cmd | args], [{:stderr, :stdout}, :sync, :stdout]) do
      {:ok, [stdout: out]} -> out
      {:ok, []} -> []
      {:error, [exit_status: _, stdout: out]} ->
        raise GitError, message: "#{out}"
    end
  end
  def git(args, false) when is_list(args) do
    "git " <> Enum.join(args, " ")
  end
end
