defimpl JaSerializer.Formatter, for: [Task] do
  def format(task), do: Task.await(task) |> JaSerializer.Formatter.format
end

defmodule RabbitCICore.StepSerializer do
  use JaSerializer
  alias RabbitCICore.Repo
  alias RabbitCICore.Step
  alias RabbitCICore.BuildSerializer

  attributes [:name, :status, :log]

  def type, do: "steps"
  def log(r, _) do
    Task.async fn ->
      Step.log(r, :no_clean)
    end
  end
end
