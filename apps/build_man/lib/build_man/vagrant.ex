defmodule BuildMan.Vagrant do
  @moduledoc """
  GenServer for Vagrant worker. Start opts should be in the format:

      [build_identifier, config]

  All Vagrant output is sent to the LogStreamer.
  """

  use GenServer
  require Logger
  require EEx
  alias BuildMan.FileHelpers
  alias BuildMan.LogStreamer
  alias RabbitCICore.Step
  alias RabbitCICore.SSHKey

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # Server callbacks
  def init([build_identifier, config]) do
    Process.flag(:trap_exit, true)
    {:ok, count_agent} = Agent.start_link(fn -> 0 end)
    send(self, :start_build)

    start_msg = "Starting: #{build_identifier}. Box: #{config.box}\n\n"
    LogStreamer.log_string(start_msg, "stdout",
                           increment_counter(count_agent),
                           config.step_id)

    {:ok, path} = FileHelpers.unique_folder("builder")
    {:ok,
     %{path: path, build: build_identifier,
       config: config, cmd: nil, counter: count_agent, success: true}}
  end

  # Exit status is set when the command finished due to a non-zero exit status.
  def handle_info({:DOWN, _ref, :process, pid, {:exit_status, _exit_status}},
                  state = %{cmd: {_, cmd_pid}}) when pid == cmd_pid do
    {:stop, :normal, %{state | success: false}}
  end

  # This is called when "vagrant up" is done.
  def handle_info({:DOWN, _ref, :process, pid, :normal},
                  state = %{build: build, cmd: {:up, cmd_pid}})
  when pid == cmd_pid do
    Logger.debug("'vagrant up' finished. #{inspect build}")
    send(self, :run_build_script)
    {:noreply, state}
  end

  # This is called when "vagrant ssh" is done.
  def handle_info({:DOWN, _ref, :process, pid, :normal},
                  state = %{build: build, cmd: {:ssh, cmd_pid}})
  when pid == cmd_pid do
    Logger.debug("'vagrant ssh' finished. #{inspect build}")
    {:stop, :normal, state}
  end

  def handle_info(:start_build, state =
        %{build: build, config: config, path: path}) do
    Logger.info("Starting vagrant build. #{inspect build}")
    Step.update_status!(config.step_id, "running")
    config =
      SSHKey.private_key_from_build_id(config.build_id)
      |> ssh_key_string(path)
      |> Map.merge(config)
    File.write(Path.join(path, "Vagrantfile"), vagrantfile(config))
    {_, pid, _} = command(["up", "--provider", "virtualbox"], state)
    {:noreply, %{state | cmd: {:up, pid}}}
  end

  defp ssh_key_string(nil, path), do: %{ssh_key_string: ""}
  defp ssh_key_string(secret_key, path) do
    key_path = Path.join([path, "git-ssh-secret-key"])
    File.write!(key_path, secret_key)
    File.chmod!(key_path, 0o600)
    ssh_config = """
    Host *
        StrictHostKeyChecking no
    """
    ssh_config_path = Path.join([path, "ssh-config-file"])
    File.write!(ssh_config_path, ssh_config)
    str = """
      config.vm.provision "file", source: "ssh-config-file", destination: "~/.ssh/config"
      config.vm.provision "file", source: "git-ssh-secret-key", destination: "~/.ssh/id_rsa"
    """
    %{ssh_key_string: str}
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

    {:noreply, %{state | cmd: {:ssh, pid}}}
  end

  def terminate(_reason, state = %{path: path, success: success, build: build,
                                  config: config, cmd: {_, cmd_pid}}) do
    Logger.debug("Vagrant build cleaning up!")
    :exec.stop(cmd_pid)

    Task.async(fn -> command(["destroy", "-f"], state, [:sync]) end)
    |> Task.await(30_000)

    case File.rm_rf(path) do
      {:ok, _} -> :ok
      {:error, err} -> Logger.error("Could not delete: #{path}. #{inspect err}")
    end

    case success do
      true -> Step.update_status!(config.step_id, "finished")
      false -> Step.update_status!(config.step_id, "failed")
    end

    Logger.info("Vagrant build finished. #{inspect build}")
  end

  defp command(args, %{config: config, build: _build, path: path,
                       counter: counter}, opts \\ [])
  when is_list(opts) do
    vagrant_cmd = System.find_executable("vagrant")
    ExExec.run(
      [vagrant_cmd | args],
      [
        {:stdout, handle_log(config, counter, "stdout")},
        {:stderr, handle_log(config, counter, "stderr")},
        # Running commands in a PTY gives us colors!
        :pty,
        # We need to kill the entire Vagrant process group because Vagrant does
        # most work in subprocesses. The `0` will tell erlexec to set the GPID
        # to the OS PID of the vagrant command.
        {:group, 0},
        :kill_group,
        :monitor,
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

  defp handle_log(%{step_id: step_id}, counter, type) do
    fn _, _, str ->
      LogStreamer.log_string(str, type, increment_counter(counter), step_id)
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
