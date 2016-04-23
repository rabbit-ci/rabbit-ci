defmodule BuildMan.LogProcessor do
  alias RabbitCICore.Repo
  alias RabbitCICore.Log
  alias RabbitCICore.Job
  alias BuildMan.LogOutput
  require Logger

  def process(log = %{type: type}) when type in ["stdout", "stderr"] do
    LogOutput.save!(log)
  end
end
