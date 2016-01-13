defimpl JaSerializer.Formatter, for: [Task] do
  def format(task) do
    task
    |> Task.await
    |> JaSerializer.Formatter.format
  end
end

defmodule RabbitCICore.StepSerializer do
  use JaSerializer
  alias RabbitCICore.Repo
  alias RabbitCICore.Step
  alias RabbitCICore.BuildSerializer

  attributes [:name, :status, :log]

  def type, do: "steps"
  def log(r, %Plug.Conn{assigns: %{no_logs: true}}), do: nil
  def log(r, _) do
    Task.async fn ->
      Step.log(r, :no_clean)
    end
  end
end
