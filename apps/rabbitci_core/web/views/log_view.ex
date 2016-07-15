defmodule RabbitCICore.LogView do
  use RabbitCICore.Web, :view
  use JaSerializer.PhoenixView
  alias RabbitCICore.JobView
  alias RabbitCICore.Log

  attributes [:stdio, :fg, :bg, :style, :io_type, :order]
  has_one :job, serializer: JobView, field: :job_id, type: "job"

  def io_type(log, _conn), do: log.type

  @spec fast_log_serializer([%Log{}] | %Log{}) :: [map] | map
  def fast_log_serializer(logs) when is_list(logs) do
    logs_serialized = for log <- logs, do: do_fast_log(log)
    %{data: logs_serialized}
  end
  def fast_log_serializer(log = %Log{}) do
    %{data: do_fast_log(log)}
  end

  defp do_fast_log(log) do
    %{stdio: log.stdio,
      io_type: log.type,
      fg: log.fg,
      bg: log.bg,
      style: log.style,
      order: log.order,
      job_id: log.job_id}
  end
end
