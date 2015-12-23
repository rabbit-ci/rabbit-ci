defmodule RabbitCICore.StepUpdaterChannel do
  use RabbitCICore.Web, :channel
  alias RabbitCICore.Endpoint
  alias RabbitCICore.Step

  def join("steps:" <> step_id, payload, socket) do
    if authorized?(payload) do
      connect_log(step_id)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (steps:lobby).
  def handle_in("shout", payload, socket) do
    broadcast socket, "shout", payload
    {:noreply, socket}
  end

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

  defp connect_log(step_id) do
    Task.start fn ->
      log =
        Repo.get!(Step, step_id)
        |> Step.log(:no_clean)
      Endpoint.broadcast("steps:#{step_id}", "set_log:step",
                         %{step_id: step_id, log: log})
    end
  end

  def publish_log(step_id, log_append) do
    Endpoint.broadcast("steps:#{step_id}", "append_log:step", log_append)
  end
end