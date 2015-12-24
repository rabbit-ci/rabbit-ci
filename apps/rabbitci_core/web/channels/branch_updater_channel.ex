defmodule RabbitCICore.BranchUpdaterChannel do
  use RabbitCICore.Web, :channel
  alias RabbitCICore.Build
  alias RabbitCICore.Endpoint

  def join("branches:" <> branch_id, payload, socket) do
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

  def new_build(branch_id, build_id) do
    Task.start fn ->
      try do
        payload = Build.json_from_id!(build_id)
        Endpoint.broadcast("branches:#{branch_id}", "new:build", payload)
      rescue e -> :ok
      end
    end
  end
end
