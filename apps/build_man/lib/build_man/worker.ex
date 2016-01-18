defmodule BuildMan.Worker do
  alias BuildMan.FileHelpers
  alias BuildMan.Worker
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
             # Path to working directory for worker.
             path: nil,
             # Callbacks are called through trigger_event/2
             callbacks: nil,
             log_handler: :not_implemented,
             provider: :not_implemented,
             files: []]

  def create(args), do: Map.merge create, Map.take(args, [:build_id, :step_id])
  def create do
    %Worker{path: FileHelpers.unique_folder!("worker"),
            callbacks: default_callbacks}
  end

  @events [:running, :finished, :failed, :error]

  defp default_callbacks do
    for event <- @events, into: %{} do
      {event, fn worker ->
        Step.update_status!(worker.step_id, to_string(event))
        {:ok, worker}
      end}
    end
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
  """
  def log(worker, io, type) do
    :not_implemented
  end

  @doc """
  Adds a file to the worker struct. Files are stored in the format: `{vm_path,
  path, permissions}` Opts:

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
end
