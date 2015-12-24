defmodule RabbitCICore.BuildUpdaterChannel do
  use RabbitCICore.Web, :channel
  alias RabbitCICore.Endpoint

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
      alias RabbitCICore.Build
      alias RabbitCICore.BuildSerializer
      import Ecto.Query, only: [from: 1, from: 2]

      payload =
      (from b in Build,
       join: br in assoc(b, :branch),
       join: p in assoc(br, :project),
       where: b.id == ^build_id,
       preload: [branch: {br, project: p}])
      |> Repo.one!
      |> BuildSerializer.format(Endpoint, %{})
      Endpoint.broadcast("builds:#{build_id}", "update:build", payload)
    end
  end
end
