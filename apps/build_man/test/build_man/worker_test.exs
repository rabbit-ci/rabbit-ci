defmodule BuildMan.WorkerTest do
  use RabbitCICore.ModelCase
  alias BuildMan.Worker
  alias RabbitCICore.Factory

  defmacrop cleanup_worker(worker) do
    quote bind_quoted: [worker: worker] do
      # This is to reduce the change of accidentally deleting some random
      # folder. All tmp dirs are in a subfolder called RabbitCI within the system
      # tmp dir.
      assert worker.path |> Path.split |> Enum.at(-2) == "RabbitCI"
      on_exit(fn -> File.rm_rf!(worker.path) end)
    end
  end

  test "Default worker creates tmp dir" do
    worker = Worker.create
    assert worker.path != nil
    assert File.dir?(worker.path)
    cleanup_worker worker
  end

  test "Files can be added to worker" do
    worker = Worker.create
    cleanup_worker worker

    worker =
      worker
      |> Worker.add_file("~/vm_file1.txt", "This is file1")
      |> Worker.add_file("~/vm_file2.txt", "This is file2", mode: 755)

    assert [{"~/vm_file2.txt", host_path2, 755},
            {"~/vm_file1.txt", host_path, nil}] = Worker.get_files(worker)
    assert File.read!(host_path) == "This is file1"
    assert File.read!(host_path2) == "This is file2"
    refute host_path == host_path2
  end

  test "Build and Step can be set in create/1" do
    worker = Worker.create %{build_id: -1, step_id: -2}
    cleanup_worker worker
    assert worker.build_id == -1
    assert worker.step_id == -2
  end

  test "Worker get_build/1" do
    step = Factory.create(:step)
    worker = Worker.create %{build_id: step.build.id, step_id: step.id}
    cleanup_worker worker
    assert Worker.get_build(worker).id == step.build.id
  end

  test "Worker get_step/1" do
    step = Factory.create(:step)
    worker = Worker.create %{build_id: step.build.id, step_id: step.id}
    cleanup_worker worker
    assert Worker.get_step(worker).id == step.id
  end

  @events [:running, :finished, :failed, :error]

  test "Worker trigger_event/2" do
    worker = Worker.create
    cleanup_worker worker
    callbacks = for event <- @events, into: %{}, do: {event, &({&1, event})}
    worker = put_in(worker.callbacks, callbacks)

    for event <- @events do
      assert Worker.trigger_event(worker, event) == {worker, event}
    end
  end

  test "Default worker trigger_event/2 callbacks" do
    step = Factory.create(:step)
    worker = Worker.create %{build_id: step.build.id, step_id: step.id}
    cleanup_worker worker

    for event <- @events do
      assert {:ok, ^worker} = Worker.trigger_event(worker, event)
      assert Worker.get_step(worker).status == to_string(event)
    end
  end
end
