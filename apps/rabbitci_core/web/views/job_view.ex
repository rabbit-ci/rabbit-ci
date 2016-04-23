defmodule RabbitCICore.JobView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView

  alias RabbitCICore.Job

  attributes [:name, :status, :log, :start_time, :finish_time]

  def attributes(job, %Plug.Conn{} = conn) do
    attrs = super(job, conn)
    case conn.assigns[:no_logs] do
      true -> Map.drop(attrs, [:log])
      _ -> attrs
    end
  end
  def attributes(job, kahn), do: super(job, kahn)

  def type, do: "jobs"
  def log(r, %Plug.Conn{assigns: %{no_logs: true}}), do: nil
  def log(r, _) do
    Task.async fn ->
      Job.log(r, :no_clean)
    end
  end
end
