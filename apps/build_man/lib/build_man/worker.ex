defmodule BuildMan.Worker do
  alias BuildMan.FileHelpers
  alias BuildMan.Worker
  alias BuildMan.LogStreamer
  alias RabbitCICore.{Repo, Build, Step}

  @moduledoc """
  The BuildMan.Worker module provides functions to interact with the
  BuildMan.Worker struct.

  The BuildMan.Worker struct is used to configure a build, _a la_
  Ecto.Changeset. The goal is to better manage build files and Vagrantfile
  generation.
  """

  defstruct [build_id: nil,
             step_id: nil,
             script: nil,
             before_script: nil,
             # Path to working directory for worker.
             path: nil,
             # Callbacks are called through trigger_event/2
             callbacks: nil,
             log_handler: :not_implemented,
             provider: :not_implemented,
             # Configuration to be passed to the provider.
             # E.g. Vagrant box.
             provider_config: nil,
             files: []]

  @doc """
  Create a %Worker{}. Args is a map that will be merged with the default worker
  values. The worker's path field may not be overridden.
  """
  def create(args), do: Map.merge create, Map.drop(args, [:path])
  def create do
    %Worker{path: FileHelpers.unique_folder!("worker"),
            callbacks: default_callbacks}
  end

  @doc """
  Deletes the Worker directory.
  """
  def cleanup!(worker) do
    with {:ok, _files} = File.rm_rf(worker.path) do
      :ok
    end
  end

  @events [:running, :finished, :failed, :error]

  # Generates the default callbacks for workers. This is used in create/0.
  defp default_callbacks do
    %{
      running: (fn worker ->
        Step.update_status!(worker.step_id, to_string(:running))
        Repo.update! Step.changeset(Worker.get_step(worker), %{start_time: Ecto.DateTime.utc})
        {:ok, worker}
      end),
      finished: (fn worker ->
        Step.update_status!(worker.step_id, to_string(:finished))
        Repo.update! Step.changeset(Worker.get_step(worker), %{finish_time: Ecto.DateTime.utc})
        {:ok, worker}
      end),
      failed: (fn worker ->
        Step.update_status!(worker.step_id, to_string(:failed))
        Repo.update! Step.changeset(Worker.get_step(worker), %{finish_time: Ecto.DateTime.utc})
        {:ok, worker}
      end),
      error: (fn worker ->
        Step.update_status!(worker.step_id, to_string(:error))
        Repo.update! Step.changeset(Worker.get_step(worker), %{finish_time: Ecto.DateTime.utc})
        {:ok, worker}
      end)
     }
  end

  @doc """
  Trigger an event on the worker. This is a synchronous operation and there is
  no guarantee that the function will not return an error. The valid events are
  those defined in `@events`.
  """
  def trigger_event(worker, event) when event in @events do
    worker.callbacks[event].(worker)
  end

  @doc """
  Default function to handle log output from a worker.

    * `io` is the log output.
    * `type` should be :stdout or :stderr.
    * `order` is used for ordering the log messages.
  """
  def log(worker, io, type, order) do
    LogStreamer.log_string(io, type, order, worker.step_id)
  end

  @doc """
  Adds a file to the worker struct. `vm_path` is relative to the home
  directory. Tilde (~) expansion does not work. Files are stored in the format:
  `{vm_path, path, permissions}` Opts:

    * `mode`: File permission _inside_ the VM. This does not affect the
      permissions for the file on the host machine.
  """
  def add_file(worker, vm_path, contents, opts \\ []) do
    permissions = Keyword.get(opts, :mode)
    path = Path.join [worker.path, "added-file-#{UUID.uuid4}"]
    File.write!(path, contents)
    put_in(worker.files, [{vm_path, path, permissions} | worker.files])
  end

  def get_files(worker), do: worker.files

  def get_build(%Worker{build_id: build_id}), do: Repo.get!(Build, build_id)

  def get_step(%Worker{step_id: step_id}), do: Repo.get!(Step, step_id)

  def get_repo(%Worker{build_id: build_id}), do: Build.get_repo_from_id!(build_id)

  def env_vars(worker = %Worker{}) do
    step = get_step(worker) |> Repo.preload([build: [branch: :project]])
    build = step.build
    branch = build.branch
    project = branch.project

    %{"RABBIT_CI_BUILD_NUMBER" => build.build_number,
      "RABBIT_CI_STEP" => step.name,
      "RABBIT_CI_BRANCH" => branch.name,
      "RABBIT_CI_PROJECT" => project.name,
      "RABBIT_CI_BOX" => worker.provider_config.box}
    |> env_vars_git(worker.provider_config.git)
  end

  defp env_vars_git(vars, %{pr: pr}), do: Map.put(vars, "RABBIT_CI_PR", pr)
  defp env_vars_git(vars, %{commit: commit}), do: Map.put(vars, "RABBIT_CI_COMMIT", commit)
end
