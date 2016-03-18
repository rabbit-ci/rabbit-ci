defmodule RabbitCICore.BuildUpdaterChannel do
  use RabbitCICore.Web, :channel
  alias RabbitCICore.Endpoint
  alias RabbitCICore.Build

  def join("builds:" <> build_id, payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end

  def update_build(build_id) do
    Task.start fn ->
      payload = Build.json_from_id!(build_id)
      Endpoint.broadcast("builds:#{build_id}", "update:build", payload)
    end
  end
end
