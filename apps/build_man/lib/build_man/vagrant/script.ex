defmodule BuildMan.Vagrant.Script do
  alias BuildMan.Worker
  alias BuildMan.GitHelpers

  def generate(worker = %Worker{provider_config: %{git: git}}) do
    step = Worker.get_step(worker)
    git = put_in(git[:repo], Worker.get_repo(worker))
    git_cmd =
      GitHelpers.clone_repo("workdir", git, false)
      |> Enum.join("\n")

    env_vars =
      worker
      |> Worker.env_vars
      |> env_vars_script

    ~s"""
    set -x
    set -e
    #{env_vars}
    #{step.before_script}
    #{git_cmd}
    cd workdir
    #{step.script}
    """
  end

  defp env_vars_script(vars) do
    for {key, val} <- vars, into: "" do
      safe_val = bash_escape(val)
      "export #{key}=\"#{safe_val}\"\n"
    end
  end

  defp bash_escape(string) when is_binary(string) do
    {output, 0} =
      System.cmd(
        "/bin/bash",
        ["-c", ~s(printf "%q" "$RABBITCI_ESCAPE")],
        env: [{"RABBITCI_ESCAPE", string}]
      )
    output
  end
  defp bash_escape(not_string) do
    not_string
    |> to_string
    |> bash_escape
  end
end
