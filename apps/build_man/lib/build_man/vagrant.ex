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

    {:ok, count_agent} = Agent.start(fn -> 0 end)

    send(self, :start_build)

    start_msg = "STDOUT: Starting: #{build_identifier}. Box: #{config.box}\n\n"
    LogStreamer.log_string(start_msg, :stdout, build_identifier,
                           increment_counter(count_agent))

    {:ok, path} = FileHelpers.unique_folder("builder")
    {:ok, %{path: path, log_streamer: pid, build: build_identifier,
            config: config, cmd: nil, counter: count_agent}}
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
    :exec.stop(cmd_pid)
    {:stop, :normal, state}
  end

  def handle_info(:start_build, state =
        %{build: _build, config: config, path: path}) do
    File.write(Path.join(path, "Vagrantfile"), vagrantfile(config))

    {_, pid, _} = command(["up", "--provider", "virtualbox"], state)
    Process.monitor(pid)
    {:noreply, %{state | cmd: {:up, pid}}}
  end

  def handle_info(:run_build_script, state =
        %{config: %{repo: _repo, script: scr, git_cmd: git_cmd}})
  do
    script = ~s"""
    set -x
    set -e
    #{git_cmd}
    cd workdir
    #{scr}
    """
    {_, pid, _} = command(["ssh", "-c", "sh", "-c", script], state)

    Process.monitor(pid)
    {:noreply, %{state | cmd: {:ssh, pid}}}
  end

  def terminate(_reason, state = %{path: path}) do
    Logger.debug("Vagrant build cleaning up!")

    Task.async(fn -> command(["destroy", "-f"], state, [:sync]) end)
    |> Task.await(30_000)

    case File.rm_rf(path) do
      {:ok, _} -> :ok
      {:error, err} -> Logger.error("Could not delete: #{path}. #{inspect err}")
    end
  end

  defp command(args, %{build: build, path: path, counter: counter}, opts \\ [])
  when is_list(opts) do
    vagrant_cmd = System.find_executable("vagrant")
    ExExec.run(
      [vagrant_cmd | args],
      [
        {:stdout, handle_log(build, counter, :stdout)},
        {:stderr, handle_log(build, counter, :stderr)},
        # Running commands in a PTY gives us colors!
        :pty,
        # We need to kill the entire Vagrant process group because Vagrant does
        # most work in subprocesses. The `0` will tell erlexec to set the GPID
        # to the OS PID of the vagrant command.
        {:group, 0},
        :kill_group,
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

  defp handle_log(build, counter, type) do
    fn _, _, str ->
      LogStreamer.log_string(str, type, build, increment_counter(counter))
    end
  end

  defp increment_counter(counter) do
    Agent.get_and_update counter, fn x ->
      y = x + 1
      {y, y}
    end
  end

  # Templates

  @template_path Path.join([__DIR__, "templates", "Vagrantfile.eex"])
  EEx.function_from_file(:def, :do_vagrantfile, @template_path, [:assigns])

  def vagrantfile(config), do: do_vagrantfile(config: config)
end
