defimpl JaSerializer.Formatter, for: [Task] do
  alias JaSerializer.Formatter

  def format(task) do
    task
    |> Task.await
    |> Formatter.format
  end
end
