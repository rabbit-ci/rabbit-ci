defmodule BuildMan.FileHelpers do
  def unique_folder(prefix \\ "") do
    system_tmp = System.tmp_dir
    {a, b, c} = :erlang.now
    n = node
    tmp_path = "#{system_tmp}RabbitCI/#{prefix}#{n}-#{a}.#{b}.#{c}"
    case File.mkdir_p(tmp_path) do
      :ok -> {:ok, tmp_path}
    end
  end
end
