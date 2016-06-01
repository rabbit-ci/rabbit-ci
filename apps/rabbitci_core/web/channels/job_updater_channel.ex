defmodule RabbitCICore.JobUpdaterChannel do
  use RabbitCICore.Web, :channel
  alias RabbitCICore.Endpoint
  alias RabbitCICore.Job

  def join("jobs:" <> job_id, payload, socket) do
    if authorized?(payload) do
      send(self, {:after_join, job_id})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:after_join, job_id}, socket) do
    Task.start fn ->
      job = Repo.get!(Job, job_id)
      log = Job.log(job)
      payload = %{job_id: job_id, log: log}
      broadcast socket, "set_log:job", payload
    end
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def publish_log(job_id, log_append) do
    Endpoint.broadcast("jobs:#{job_id}", "append_log:job", log_append)
  end
end
