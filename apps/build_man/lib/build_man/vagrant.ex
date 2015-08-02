defmodule BuildMan.Vagrant do
  require EEx
  alias BuildMan.FileHelpers

  def vagrantfile(config) do
    do_vagrantfile(config: config)
  end

  def run(config) do
    {:ok, path} = FileHelpers.unique_folder("builder")
    File.write(Path.join(path, "Vagrantfile"), vagrantfile(config))

    command(["up"], path)
    script = ~s"""
    set -x
    git clone #{config.repo} workdir
    cd workdir
    #{config.script}
    """
    command(["ssh", "-c", "sh", "-c", script], path)
    command(["destroy", "-f"], path)
  end

  defp command(args, path) do
    vagrant_cmd = System.find_executable("vagrant")
    ExExec.run([vagrant_cmd | args],
               [{:stdout, &handle_out/3}, {:stderr, &handle_err/3},
                :sync, cd: path])
  end

  defp handle_out(_, _, s) do
    str = remove_str_newline(s)
    IO.puts str
    # "stdout: #{s}"
  end

  defp handle_err(_, _, s) do
    str = remove_str_newline(s)
    IO.puts "STDERR: #{str}"
    # "stderr: #{s}"
  end

  defp remove_str_newline(str) do
    case String.last(str) do
      "\n" -> String.slice(str, 0..-2)
      _ -> str
    end
  end

  p = Path.join(["lib", "build_man", "templates", "Vagrantfile.eex"])
  EEx.function_from_file(:defp, :do_vagrantfile, p, [:assigns])
end
