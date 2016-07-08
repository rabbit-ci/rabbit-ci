defmodule RabbitCICore.RecordPubSubChannel do
  use RabbitCICore.Web, :channel
  alias RabbitCICore.Endpoint
  alias RabbitCICore.{Build, Log}
  alias RabbitCICore.LogView
  alias RabbitCICore.Repo
  alias Phoenix.Socket.Broadcast

  def join("record_pubsub", _payload, socket) do
    {:ok, socket}
  end

  @supported_records ["projects", "branches", "builds", "steps", "jobs", "logs"]

  def handle_in("subscribe", map = %{}, socket) do
    for {k, v} <- map, k in @supported_records do
      for id <- List.wrap(v) do
        do_subscribe(k, id)
      end
    end
    {:reply, :ok, socket}
  end

  def handle_in("unsubscribe", map = %{}, socket) do
    for {k, v} <- map, k in @supported_records do
      for id <- List.wrap(v) do
        Endpoint.unsubscribe("#{k}:#{id}")
      end
    end
    {:reply, :ok, socket}
  end

  intercept ["json_api_payload"]

  def handle_info(%Broadcast{topic: _, event: "json_api_payload" = ev, payload: pay}, socket) do
    push socket, ev, pay
    {:noreply, socket}
  end

  def update_build(build_id) do
    payload = Build.json_from_id!(build_id)
    Endpoint.broadcast("builds:#{build_id}", "json_api_payload", payload)
  end

  def new_build(branch_id, build_id) do
    payload = Build.json_from_id!(build_id)
    Endpoint.broadcast("branches:#{branch_id}", "json_api_payload", payload)
  end

  def new_log(log) do
    payload = JaSerializer.format(LogView, log, Endpoint, %{})
    Endpoint.broadcast("logs:#{log.job_id}", "json_api_payload", payload)
  end

  defp do_subscribe(k = "logs", id) do
    import Ecto.Query
    Endpoint.subscribe("#{k}:#{id}")
    Task.start fn ->
      data =
        from(l in Log, where: l.job_id == ^id)
        |> Repo.all
      payload = JaSerializer.format(LogView, data, Endpoint, %{})
      Endpoint.broadcast("logs:#{id}", "json_api_payload", payload)
    end
  end
  defp do_subscribe(k, id), do: Endpoint.subscribe("#{k}:#{id}")
end
