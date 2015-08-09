defmodule BuildMan.FileHelpers do
  def unique_folder(prefix \\ "") do
    dir_name = "#{prefix}-#{UUID.uuid4()}"
    tmp_path = Path.join([System.tmp_dir, "RabbitCI", dir_name])

    case File.mkdir_p(tmp_path) do
      :ok -> {:ok, tmp_path}
    end
  end
end
