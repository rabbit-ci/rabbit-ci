defmodule BuildMan.FileHelpers do
  def unique_folder(prefix \\ "") do
    system_tmp = System.tmp_dir
    unique_hash = :erlang.phash2(make_ref)
    tmp_path = "#{system_tmp}RabbitCI/#{prefix}#{unique_hash}"
    case File.mkdir_p(tmp_path) do
      :ok -> {:ok, tmp_path}
      a = {:error, _} -> a
    end
  end
end
