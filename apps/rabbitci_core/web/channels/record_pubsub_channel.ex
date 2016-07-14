defmodule RabbitCICore.RecordPubSubChannel do
  @moduledoc """
  RecordPubSubChannel allows clients to subscribe to new records and record
  updates. Records are sent as JSON-API encoded documents. To subscribe to a
  record channel, send a message to the `subscribe` channel with a map whose
  keys are the record's channel you want to subscribe to and the value can be a
  single id or a list of ids to subscribe to. Unsubscribing is done exactly the
  same through the `unsubscribe` topic. E.g.

  ```
  channel.push("subscribe", {branches: 123, builds: [456, 789]})
  ```

  Records will be sent on the `json_api_payload` topic. The payload is the
  JSON-API encoded document.

  Available channels:
  - `branches:<branch id>`
    - New builds.
  - `builds:<build id>`
    - Build updates.
    - New Jobs
    - New Steps
  - `logs:<job id>`
    - All logs for job will be sent on connect.
    - New logs.
  """

  use RabbitCICore.Web, :channel
  alias RabbitCICore.Endpoint
  alias RabbitCICore.{Log}
  alias RabbitCICore.{LogView, BuildView, StepView, JobView}
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

  defp build_json(build) do
    data = Repo.preload(build, [branch: :project, steps: :jobs])
    JaSerializer.format(BuildView, data, Endpoint, %{})
  end

  def update_build(build) do
    payload = build_json(build)
    Endpoint.broadcast("builds:#{build.id}", "json_api_payload", payload)
  end

  def new_build(build) do
    payload = build_json(build)
    Endpoint.broadcast("branches:#{build.branch_id}", "json_api_payload", payload)
  end

  def new_step(step) do
    payload = JaSerializer.format(StepView, step, Endpoint, %{})
    Endpoint.broadcast("builds:#{step.build_id}", "json_api_payload", payload)
  end

  def new_job(job) do
    job = Repo.preload(job, [step: :build])
    payload = JaSerializer.format(JobView, job, Endpoint, %{})
    Endpoint.broadcast("builds:#{job.step.build_id}", "json_api_payload", payload)
  end

  def new_log(log) do
    Task.start fn ->
      payload = JaSerializer.format(LogView, log, Endpoint, %{})
      Endpoint.broadcast("logs:#{log.job_id}", "json_api_payload", payload)
    end
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
