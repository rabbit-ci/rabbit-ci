defmodule BuildMan.Vagrant.Vagrantfile do
  alias BuildMan.Worker

  @moduledoc """
  Responsible for generating a Vagrantfile from a worker definition.
  """

  def generate(%Worker{provider_config: %{box: box},
                       files: files}) do
    instructions = List.flatten [{:begin}, parse_box(box), parse_files(files), {:end}]
    for instruction <- instructions do
      List.wrap generate_lines(instruction)
    end
    |> List.flatten
    |> Enum.intersperse("\n")
    |> to_string
  end
  def generate(_worker), do: {:error, :invalid_worker}

  defp parse_box(box), do: {:box, box}
  defp parse_files(files) do
    for file <- files, do: {:add_file, file}
  end

  defp generate_lines({:add_file, {vm_path, path, permissions}})
  when is_bitstring(vm_path) and is_bitstring(path) do
    safe_vm_path = Poison.encode!(vm_path)
    safe_path = Poison.encode!(path)

    ["config.vm.provision 'file', source: #{safe_path}, destination: #{safe_vm_path}",
     chmod(vm_path, permissions)]
  end
  defp generate_lines({:box, box}) when is_bitstring(box) do
    "config.vm.box = #{Poison.encode!(box)}"
  end
  defp generate_lines({:begin}) do
    """
    Vagrant.configure(2) do |config|
      config.vm.provision "fix-no-tty", type: "shell" do |s|
        s.privileged = false
        s.inline = "sudo sed -i '/tty/!s/mesg n/tty -s \\&\\& mesg n/' /root/.profile"
      end

      config.ssh.insert_key = false
      config.vm.synced_folder ".", "/vagrant", disabled: true

      config.vm.provider "virtualbox" do |vb|
        vb.linked_clone = true
      end
    """
  end
  defp generate_lines({:end}), do: "end\n"

  @chmod_script "chmod $1 $2"
  defp chmod(vm_path, nil), do: []
  defp chmod(vm_path, permissions) do
    shell_provisioner(@chmod_script, [permissions, vm_path])
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
