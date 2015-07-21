defmodule BuildMan.FileHelpers do
  def unique_folder(prefix \\ "") do
    system_tmp = System.tmp_dir
    {a, b, c} = :erlang.now
    n = node
    dir_name = "#{prefix}#{n}-#{a}.#{b}.#{c}"
    tmp_path = Path.join([system_tmp, "RabbitCI", dir_name])
    case File.mkdir_p(tmp_path) do
      :ok -> {:ok, tmp_path}
    end
  end
end
