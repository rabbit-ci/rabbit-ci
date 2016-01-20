defmodule BuildMan.WorkerSupport do
  defmacro cleanup_worker(worker) do
    quote bind_quoted: [worker: worker] do
      # This is to reduce the change of accidentally deleting some random
      # folder. All tmp dirs are in a subfolder called RabbitCI within the system
      # tmp dir.
      assert worker.path |> Path.split |> Enum.at(-2) == "RabbitCI"
      on_exit(fn -> File.rm_rf!(worker.path) end)
    end
  end
end
