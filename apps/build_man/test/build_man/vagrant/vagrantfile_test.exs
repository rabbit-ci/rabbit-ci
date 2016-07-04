defmodule BuildMan.Vagrant.VagrantfileTest do
  use RabbitCICore.ModelCase, async: true
  alias BuildMan.Vagrant.Vagrantfile
  alias BuildMan.Worker
  alias RabbitCICore.Factory
  import BuildMan.WorkerSupport, only: [cleanup_worker: 1]

  defmacrop assert_lines({op, _meta, [left, right]}) do
    quote do
      left = split_and_sort(unquote(left))
      right = split_and_sort(unquote(right))
      assert unquote(op)(left, right)
    end
  end

  defp split_and_sort(string) do
    string
    |> String.split("\n")
    |> Enum.map(&String.strip/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.sort
  end

  test "Worker missing config fields returns error" do
    worker = Worker.create
    cleanup_worker worker
    assert {:error, :invalid_worker} = Vagrantfile.instructions(worker)
  end

  test "Minimal Vagrantfile" do
    job = Factory.insert(:job, box: "test/box")
    worker = Worker.create(%{job_id: job.id, provider: "virtualbox"})
    cleanup_worker worker

    lines =
      with {:ok, instructions} <- Vagrantfile.instructions(worker),
      do: Vagrantfile.vagrantfile(instructions)

    assert_lines lines ==
      ~S"""
      Vagrant.configure(2) do |config|
        config.ssh.insert_key = false
        config.vm.synced_folder ".", "/vagrant", disabled: true

        config.vm.provider "virtualbox" do |vb|
          vb.linked_clone = true
        end

        config.vm.box = "test/box"
      end
      """
  end

  test "Worker with single file (default permissions)" do
    job = Factory.insert(:job, box: "test/box")
    worker =
      Worker.create(%{job_id: job.id, provider: "virtualbox"})
      |> Worker.add_file("testing-file.txt", "This is a test")
    cleanup_worker worker

    lines =
      with {:ok, instructions} <- Vagrantfile.instructions(worker),
      do: Vagrantfile.vagrantfile(instructions)
      |> String.replace(~r/(source: \").*(\",)/, "\\1source_file\\2")

    assert_lines lines ==
    ~S"""
    Vagrant.configure(2) do |config|
      config.ssh.insert_key = false
      config.vm.synced_folder ".", "/vagrant", disabled: true

      config.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
      end

    config.vm.box = "test/box"

    config.vm.provision 'file', source: "source_file", destination: "testing-file.txt"
    end
    """
  end

  test "Worker with single file (custom permissions)" do
    job = Factory.insert(:job, box: "test/box")
    worker =
      Worker.create(%{job_id: job.id, provider: "virtualbox"})
      |> Worker.add_file("testing-file.txt", "This is a test", mode: 755)
    cleanup_worker worker

    lines =
      with {:ok, instructions} <- Vagrantfile.instructions(worker),
      do: Vagrantfile.vagrantfile(instructions)
      |> String.replace(~r/(source: \").*(\",)/, "\\1source_file\\2")

    assert_lines lines ==
    ~S"""
    Vagrant.configure(2) do |config|
      config.ssh.insert_key = false
      config.vm.synced_folder ".", "/vagrant", disabled: true

      config.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
      end

    config.vm.box = "test/box"

    config.vm.provision 'file', source: "source_file", destination: "testing-file.txt"

    config.vm.provision "shell" do |s|
      s.inline = "chmod $1 $2"
      s.args   = [755,"testing-file.txt"]
    end
    end
    """
  end

end
