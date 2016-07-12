defmodule BuildMan.Vagrant.Vagrantfile do
  alias BuildMan.Worker
  alias BuildMan.Vagrant.Vagrantfile

  @moduledoc """
  Responsible for generating a Vagrantfile from a worker definition.
  """

  def instructions(worker = %Worker{files: files, job_id: job_id})
  when not is_nil(job_id) do
    box = Worker.get_job(worker).box
    provider = Worker.provider(worker)
    {:ok,
      List.flatten([
        {:begin},
        {:provider, provider},
        parse_box(box, provider),
        parse_files(files, provider),
        {:end}
      ])
    }
  end
  def instructions(_worker), do: {:error, :invalid_worker}

  def vagrantfile(instructions) do
    for instruction <- instructions do
      List.wrap generate_lines(instruction)
    end
    |> List.flatten
    |> Enum.intersperse("\n")
    |> to_string
  end

  def dockerfile(instructions) do
    for instruction <- instructions do
      List.wrap generate_docker_lines(instruction)
    end
    |> List.flatten
    |> Enum.intersperse("\n")
    |> to_string
  end

  @b2d_vagrantfile_contents ~S"""
  Vagrant.configure("2") do |config|
    config.ssh.username = 'docker'
    config.ssh.password = 'tcuser'
    config.vm.box = "hashicorp/boot2docker"
    config.ssh.insert_key = true
    config.vm.define "rabbit-ci-boot2docker"
  end
  """

  def write_files!(worker) do
    {:ok, instructions} = Vagrantfile.instructions(worker)
    File.write!(Path.join(worker.path, "Vagrantfile"), vagrantfile(instructions))

    if Worker.provider(worker) == "docker" do
      File.write!(Path.join(worker.path, "Dockerfile"), dockerfile(instructions))
      File.write!(Path.join(worker.path, "rabbit-ci-B2D-Vagrantfile"), @b2d_vagrantfile_contents)
    end
  end

  defp parse_box(box, provider), do: {:box, box, provider}
  defp parse_files(files, provider) do
    for file <- files, do: {:add_file, file, provider}
  end

  defp generate_docker_lines({:add_file, {vm_path, path, permissions}, _provider})
  when is_bitstring(vm_path) and is_bitstring(path) do
    safe_vm_path = Poison.encode!(vm_path)
    safe_path =
      path
      |> Path.basename
      |> Poison.encode!

    ["ADD [#{safe_path}, #{safe_vm_path}]", docker_chmod(safe_vm_path, permissions)]
  end
  defp generate_docker_lines({:box, box, "docker"}) when is_bitstring(box) do
    # Job changeset validates format.
    ["FROM #{box}", "WORKDIR /root"]
  end
  defp generate_docker_lines(_), do: []

  defp generate_lines({:add_file, {vm_path, path, permissions}, _provider})
  when is_bitstring(vm_path) and is_bitstring(path) do
    safe_vm_path = Poison.encode!(vm_path)
    safe_path = Poison.encode!(path)

    ["config.vm.provision 'file', source: #{safe_path}, destination: #{safe_vm_path}",
     chmod(vm_path, permissions)]
  end
  defp generate_lines({:box, box, "virtualbox"}) when is_bitstring(box) do
    "config.vm.box = #{Poison.encode!(box)}"
  end
  defp generate_lines({:box, _box, _provider}), do: []
  defp generate_lines({:begin}) do
    ~S"""
    Vagrant.configure(2) do |config|
      config.ssh.insert_key = false
      config.vm.synced_folder ".", "/vagrant", disabled: true
    """
  end
  defp generate_lines({:end}), do: "end\n"
  defp generate_lines({:provider, "virtualbox"}) do
    ~S"""
    config.vm.provider "virtualbox" do |vb|
      vb.linked_clone = true
    end
    """
  end
  defp generate_lines({:provider, "docker"}) do
    ~S"""
    config.vm.provider "docker" do |d|
      d.force_host_vm = false
      d.remains_running = false
      d.vagrant_machine = "rabbit-ci-boot2docker"
      d.vagrant_vagrantfile = "rabbit-ci-B2D-Vagrantfile"
      d.build_dir = "."
      d.build_args = ["--no-cache"]
    end
    """
  end

  @chmod_script "chmod $1 $2"
  defp chmod(_vm_path, nil), do: []
  defp chmod(vm_path, permissions) do
    shell_provisioner(@chmod_script, [permissions, vm_path])
  end

  defp docker_chmod(_safe_vm_path, nil), do: []
  defp docker_chmod(safe_vm_path, permissions) do
    "RUN [\"chmod\", #{Poison.encode!(to_string permissions)}, #{safe_vm_path}]"
  end

  defp shell_provisioner(inline, args)
  when is_bitstring(inline) and is_list(args) do
    """
    config.vm.provision "shell" do |s|
      s.inline = #{Poison.encode!(inline)}
      s.args   = #{Poison.encode!(args)}
    end
    """
  end
end
