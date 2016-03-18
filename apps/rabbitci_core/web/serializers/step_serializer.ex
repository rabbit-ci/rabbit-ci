defimpl JaSerializer.Formatter, for: [Task] do
  alias JaSerializer.Formatter

  def format(task) do
    task
    |> Task.await
    |> Formatter.format
  end
end

defmodule RabbitCICore.StepSerializer do
  use JaSerializer
  alias RabbitCICore.Repo
  alias RabbitCICore.Step
  alias RabbitCICore.BuildSerializer

  attributes [:name, :status, :log, :start_time, :finish_time]

  def type, do: "steps"
  def log(r, %Plug.Conn{assigns: %{no_logs: true}}), do: nil
  def log(r, _) do
    Task.async fn ->
      Step.log(r, :no_clean)
    end
  end
end
