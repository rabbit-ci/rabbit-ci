defmodule BuildMan.Vagrant do
  @moduledoc """
  GenServer for Vagrant worker.
  """

  use GenServer
  require Logger
  require EEx
  alias BuildMan.FileHelpers
  alias BuildMan.Worker
  alias BuildMan.Vagrant.Script
  alias BuildMan.Vagrant.Vagrantfile
  alias RabbitCICore.Job
  alias RabbitCICore.SSHKey

  # Client API
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  # Server callbacks
  def init([config, {chan, tag}]) do
    {:ok, count_agent} = Agent.start_link(fn -> 0 end)
    send(self, :start_build)

    worker = Worker.create(config)

    Worker.log(worker, "Starting: #{worker.build_id}.#{worker.job_id}.\n\n",
               :stdout, increment_counter(count_agent))

    {:ok, %{worker: worker,
            cmd: nil,
            counter: count_agent,
            success: true,
            chan: chan,
            tag: tag}}
  end

  defp log_debug(worker, str) do
    Logger.debug("#{str} #{worker.build_id}.#{worker.job_id}")
  end

  # Exit status is set when the command finished due to a non-zero exit status.
  def handle_info({:DOWN, _ref, :process, pid, {:exit_status, _exit_status}},
                  state = %{cmd: {_, cmd_pid}}) when pid == cmd_pid do
    {:stop, :normal, %{state | success: false}}
  end

  # This is called when "vagrant up" is done.
  def handle_info({:DOWN, _ref, :process, pid, :normal},
                  state = %{cmd: {:up, cmd_pid}})
  when pid == cmd_pid do
    log_debug(state.worker, "'vagrant up' finished.")
    send(self, :run_build_script)
    {:noreply, state}
  end

  # This is called when "vagrant ssh" is done.
  def handle_info({:DOWN, _ref, :process, pid, :normal},
                  state = %{cmd: {:ssh, cmd_pid}})
  when pid == cmd_pid do
    log_debug(state.worker, "'vagrant ssh' finished.")
    {:stop, :normal, state}
  end

  def handle_info(:start_build, state = %{worker: worker}) do
    log_debug(state.worker, "Vagrant build starting.")
    Worker.trigger_event(worker, :running)

    worker = add_ssh_key(worker, SSHKey.private_key_from_build_id(worker.build_id))
    state = put_in(state.worker, worker)

    File.write(Path.join(worker.path, "Vagrantfile"), Vagrantfile.generate(worker))
    {_, pid, _} = command(["up", "--provider", "virtualbox"], state)
    {:noreply, %{state | cmd: {:up, pid}}}
  end

  def handle_info(:run_build_script, state = %{worker: worker}) do
    script = Script.generate(worker)
    Logger.debug("Running script:\n#{script}")
    {_, pid, _} = command(["ssh", "-c", "sh", "-c", script], state)
    {:noreply, %{state | cmd: {:ssh, pid}}}
  end

  def terminate(_reason, state = %{worker: worker, success: success, cmd: {_, cmd_pid}}) do
    log_debug(state.worker, "Vagrant build cleaning up.")

    :exec.stop(cmd_pid)

    Task.async(fn -> command(["destroy", "-f"], state, [:sync]) end)
    |> Task.await(30_000)

    File.rm_rf!(worker.path)

    AMQP.Basic.ack(state.chan, state.tag)

    case success do
      true -> Worker.trigger_event(worker, :finished)
      false -> Worker.trigger_event(worker, :failed)
    end

    log_debug(worker, "Vagrant build finished.")
    :ok
  end

  defp add_ssh_key(worker, nil), do: worker
  defp add_ssh_key(worker, secret_key) do
    ssh_config = """
    Host *
        StrictHostKeyChecking no
    """
    worker
    |> Worker.add_file(".ssh/config", ssh_config)
    |> Worker.add_file(".ssh/id_rsa", secret_key, mode: 600)
  end

  defp command(args, %{worker: worker, counter: counter}, opts \\ [])
  when is_list(opts) do
    vagrant_cmd = System.find_executable("vagrant")
    ExExec.run(
      [vagrant_cmd | args],
      [
        {:stdout, handle_log(worker, counter, :stdout)},
        {:stderr, handle_log(worker, counter, :stderr)},
        # Running commands in a PTY gives us colors!
        :pty,
        # We need to kill the entire Vagrant process group because Vagrant does
        # most work in subprocesses. The `0` will tell erlexec to set the GPID
        # to the OS PID of the vagrant command.
        {:group, 0},
        :kill_group,
        :monitor,
        # Run all commands inside our temporary directory.
        cd: worker.path,
      ] |> unique_merge(opts)
    )
   end

  # opts2 will override duplicate keys in opts1.
  defp unique_merge(opts1, opts2) do
    opts2 ++ opts1
    |> Enum.uniq(fn x ->
      case x do
        {y, _} -> y
        z -> z
      end
    end)
  end

  defp handle_log(worker, counter, type) do
    fn _, _, str ->
      Worker.log(worker, str, type, increment_counter(counter))
    end
  end

  defp increment_counter(counter) do
    Agent.get_and_update counter, fn x ->
      y = x + 1
      {y, y}
    end
  end
end
