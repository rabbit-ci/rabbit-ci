defmodule BuildMan.GitHelpers do
  require EEx
  require Logger
  alias BuildMan.FileHelpers

  defmodule GitError, do: defexception message: "Git errored!"

  def clone_repo_with_ssh_key(path, git_info, secret_key) do
    {helper_folder, helper_path} = ssh_helper!(secret_key)
    clone_repo(path, git_info, true,
               [{:env, [{'GIT_SSH', to_char_list(helper_path)}]}])
    File.rm_rf!(helper_folder)
  end

  def clone_repo(_, _, should_run \\ true, exec_opts \\ [])
  def clone_repo(path, %{repo: repo, commit: commit}, should_run, exec_opts) do
    clone = git(["clone", repo, path], should_run)

    cmds = [["checkout", "-qf", commit],
            ["rev-parse", "HEAD"]]

    [clone | (for cmd <- cmds, do: git(cmd, should_run,
                                       [path: path, exec_opts: exec_opts]))]
  end
  def clone_repo(path, %{repo: repo, pr: pr}, should_run, exec_opts) do
    clone = git(["clone", repo, path], should_run)

    cmds = [["fetch", "origin", "+refs/pull/#{pr}/merge:pr/#{pr}"],
            ["checkout", "-qf", "pr/#{pr}"],
            ["rev-parse", "HEAD"]]

    [clone | (for cmd <- cmds, do: git(cmd, should_run,
                                       [path: path, exec_opts: exec_opts]))]
  end

  def git(args, should_run, opts \\ [])
  def git(args, true, opts) when is_list(args) do
    args =
      case Keyword.get(opts, :path) do
        nil -> args
        path -> ["-C", path] ++ args
      end

    exec_opts = Keyword.get(opts, :exec_opts, [])
    git_cmd = System.find_executable("git")

    case ExExec.run([git_cmd | args],
                    [{:stderr, :stdout}, :sync, :stdout | exec_opts]) do
      {:ok, [stdout: out]} -> out
      {:ok, []} -> []
      {:error, [exit_status: _, stdout: out]} ->
        raise GitError, message: "#{out}"
    end
  end
  def git(args, false, opts) when is_list(args) do
    args =
      case Keyword.get(opts, :path) do
        nil -> args
        path -> ["-C", path] ++ args
      end

    "git " <> Enum.join(args, " ")
  end

  @template_path Path.join([__DIR__, "templates", "git-ssh-helper.sh.eex"])
  EEx.function_from_file(:defp, :do_ssh_helper, @template_path, [:assigns])

  # Takes a secret key as a binary and returns a path to a script that can be
  # used by setting the GIT_SSH environment variable.
  def ssh_helper!(secret_key) do
    # Create a new temporary folder.
    {:ok, path} = FileHelpers.unique_folder("git-ssh-helper")
    # Write the secret key to a file in the temp folder.
    key_path = Path.join([path, "git-ssh-secret-key"])
    File.write!(key_path, secret_key)
    File.chmod!(key_path, 0o600)
    # Write the helper script to a file in the temp folder.
    helper = do_ssh_helper(key_path: key_path)
    helper_path = Path.join([path, "git-ssh-helper.sh"])
    File.write!(helper_path, helper)
    File.chmod!(helper_path, 0o700)
    {path, helper_path}
  end
end
