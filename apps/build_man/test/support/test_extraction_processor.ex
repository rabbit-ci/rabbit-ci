defmodule BuildMan.TestExtractionProcessor do
  def process_config(_, content, _, _) do
    pid = Application.get_env(:build_man, :config_extraction_processor_pid)
    send(pid, {:replied, content})
  end

  def done do
    pid = Application.get_env(:build_man, :config_extraction_processor_pid)
    send(pid, :finished)
  end
end
