defmodule BuildMan.Vagrant.Script do
  alias BuildMan.Worker
  alias BuildMan.GitHelpers

  def generate(worker = %Worker{script: scr,
                                before_script: before_scr,
                                provider_config: %{git: git}}) do
    git = put_in(git[:repo], Worker.get_repo(worker))
    git_cmd =
      GitHelpers.clone_repo("workdir", git, false)
      |> Enum.join("\n")

    env_vars =
      worker
      |> Worker.env_vars
      |> env_vars_script

    ~s"""
    set -v
    set -e
    #{env_vars}
    #{before_scr}
    #{git_cmd}
    cd workdir
    #{scr}
    """
  end

  defp env_vars_script(vars) do
    for {key, val} <- vars, into: "" do
      safe_val = Poison.encode!(val)
      "export #{key}=#{safe_val}\n"
    end
  end
end
