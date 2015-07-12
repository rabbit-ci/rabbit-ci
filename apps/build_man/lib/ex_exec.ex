defmodule ExExec do
  @moduledoc """
  This module provides (minimal) Elixir bindings to
  [erlexec](http://saleyn.github.io/erlexec/).
  """

  def start_link(options \\ []) do
    :exec.start_link(options)
  end

  def start(options \\ []) do
    :exec.start(options)
  end

  @doc ~S"""
  Run command in the exec process. If a string is provided, it will be executed
  in the user's shell. If a list of strings is provided, it will execute that
  command with the provided arguments.

  For a list of options that can be supplied, see the erlexec homepage:
  http://saleyn.github.io/erlexec/

  ## Examples

      iex> ExExec.run(["/bin/echo", "test"], [:sync, :stdout])
      {:ok, [stdout: ["test\n"]]}

      iex> ExExec.run("echo test >&2", [:sync, :stderr])
      {:ok, [stderr: ["test\n"]]}

  """
  def run(command = [a|_], options) when is_list(command) and is_binary(a) do
    q = Enum.map(command, &(to_char_list(&1)))
    run(q, options)
  end

  def run(command, options) when is_binary(command) do
    to_char_list(command) |> run(options)
  end

  def run(command, options) do
    :exec.run(command, Enum.map(options, &fix_option/1))
  end

  defp fix_option({key, value}) when is_binary(value) do
    {key, to_char_list(value)}
  end
  defp fix_option(a), do: a
end
