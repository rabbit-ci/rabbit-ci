defmodule RabbitCICore.StepUpdaterChannel do
  use RabbitCICore.Web, :channel
  alias RabbitCICore.Endpoint
  alias RabbitCICore.Step

  def join("steps:" <> step_id, payload, socket) do
    if authorized?(payload) do
      send(self, {:after_join, step_id})
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_info({:after_join, step_id}, socket) do
    Task.start fn ->
      log =
        Repo.get!(Step, step_id)
        |> Step.log(:no_clean)
      payload = %{step_id: step_id, log: log}
      broadcast socket, "set_log:step", payload
    end
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  # def handle_in("ping", payload, socket) do
  #   {:reply, {:ok, payload}, socket}
  # end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def publish_log(step_id, log_append) do
    Endpoint.broadcast("steps:#{step_id}", "append_log:step", log_append)
  end
end
