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

  def attributes(step, conn) do
    attrs = super(step, conn)
    case conn.assigns[:no_logs] do
      true -> Map.drop(attrs, [:log])
      _ -> attrs
    end
  end

  def type, do: "steps"
  def log(r, %Plug.Conn{assigns: %{no_logs: true}}), do: nil
  def log(r, _) do
    Task.async fn ->
      Step.log(r, :no_clean)
    end
  end
end
