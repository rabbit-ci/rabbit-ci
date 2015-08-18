defmodule BuildMan.Vagrant do
  @moduledoc """
  GenServer for Vagrant worker. Start opts should be in the format:

      [build_identifier, config]

  The worker will stop whenever the build is done or when the LogStreamer
  dies. All Vagrant output is sent to the LogStreamer.
  """

  use GenServer
  require Logger
  require EEx
  alias BuildMan.FileHelpers
  alias BuildMan.LogStreamer

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # Server callbacks

  def init([build_identifier, config]) do
    {:ok, pid} = LogStreamer.start({self, build_identifier})
    Process.monitor(pid)

    send(self, :start_build)

    {:ok, path} = FileHelpers.unique_folder("builder")
    {:ok, %{path: path, log_streamer: pid, build: build_identifier,
            config: config, cmd: nil}}
  end

  # This is called when "vagrant up" is done.
  def handle_info({:DOWN, _ref, :process, pid, _reason},
                  state = %{cmd: {:up, cmd_pid}}) when pid == cmd_pid do
    Logger.debug("'vagrant up' finished.")
    send(self, :run_build_script)
    {:noreply, state}
  end

  # This is called when "vagrant ssh" is done.
  def handle_info({:DOWN, _ref, :process, pid, _reason},
                  state = %{build: build, cmd: {:ssh, cmd_pid}})
  when pid == cmd_pid do
    Logger.info "Vagrant worker finished #{build}. Going down..."
    {:stop, :normal, state}
  end

  # This gets called when the LogStreamer goes down.
  def handle_info({:DOWN, _ref, :process, _pid, _reason},
                  state = %{cmd: {_, cmd_pid}}) do
    Logger.warn "Vagrant worker going down..."
    # SIGINT will tell Vagrant to gracefully shutdown.
    :exec.kill(cmd_pid, 2)
    # Wait for Vagrant...
    :timer.sleep(2000)
    # We're not patient. Kill Vagrant if it's still running.
    :exec.stop(cmd_pid)
    {:stop, :normal, state}
  end

  def handle_info(:start_build, state =
        %{build: build, config: config, path: path}) do
    File.write(Path.join(path, "Vagrantfile"), vagrantfile(config))

    {_, pid, _} = command(["up", "--provider", "virtualbox"], state)
    Process.monitor(pid)
    {:noreply, %{state | cmd: {:up, pid}}}
  end

  def handle_info(:run_build_script, state =
        %{config: %{repo: repo, script: scr}}) do
    script = ~s"""
    set -x
    git clone #{repo} workdir
    cd workdir
    #{scr}
    """
    {_, pid, _} = command(["ssh", "-c", "sh", "-c", script], state)

    Process.monitor(pid)
    {:noreply, %{state | cmd: {:ssh, pid}}}
  end

  def terminate(_reason, state = %{path: path}) do
    Logger.debug("Vagrant build cleaning up!")
    command(["destroy", "-f"], state, [:sync])
    case File.rm_rf(path) do
      {:ok, _} -> :ok
      {:error, err} -> Logger.error("Could not delete: #{path}. #{inspect err}")
    end
  end

  defp command(args, %{build: build, path: path}, opts \\ [])
  when is_list(opts) do
    vagrant_cmd = System.find_executable("vagrant")
    ExExec.run(
      [vagrant_cmd | args],
      [
        {:stdout, handle_log(build, :stdout)},
        {:stderr, handle_log(build, :stderr)},
        # Vagrant will not terminate from a signal in the "importing
        # box" stage unless it is running in a PTY. Running commands in
        # a PTY also gives us colors!
        :pty,
        # Run all commands inside our temporary directory.
        cd: path,
      ] |> unique_merge(opts)
    )
   end

  # opts2 will override duplicate keys in opts1.
  defp unique_merge(opts1, opts2) do
    opts2 ++ opts1
    |> Enum.uniq fn x ->
      case x do
        {y, _} -> y
        z -> z
      end
    end
  end

  defp handle_log(build, type) do
    fn _, _, str ->
      LogStreamer.log_string(str, type, build)
    end
  end

  # Templates

  @template_path Path.join([__DIR__, "templates", "Vagrantfile.eex"])
  EEx.function_from_file(:def, :do_vagrantfile, @template_path, [:assigns])

  def vagrantfile(config), do: do_vagrantfile(config: config)
end
