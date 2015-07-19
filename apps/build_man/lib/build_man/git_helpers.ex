defmodule BuildMan.GitHelpers do
  defmodule GitError, do: defexception message: "Git errored!"
  require Logger

  def clone_repo(path, %{"repo" => repo, "commit" => commit}) do
    git(["clone", repo, path])
    git(["checkout", "-qf", commit], path: path)
    git(["rev-parse", "HEAD"], path: path)
  end

  def clone_repo(path, %{"repo" => repo, "pr" => pr}) do
    git(["clone", repo, path])
    git(["fetch", "origin", "+refs/pull/#{pr}/merge:pr/#{pr}"], path: path)
    git(["checkout", "-qf", "pr/#{pr}"], path: path)
    git(["rev-parse", "HEAD"], path: path)
  end

  def git(args, [path: path]) when is_list(args) do
    git(["-C", path] ++ args)
  end

  def git(args) when is_list(args) do
    git_cmd = System.find_executable("git")

    case ExExec.run([git_cmd | args], [{:stderr, :stdout}, :sync, :stdout]) do
      {:ok, [stdout: out]} -> out
      {:ok, []} -> []
      {:error, [exit_status: _, stdout: out]} ->
        raise GitError, message: "#{out}"
    end
  end
end
