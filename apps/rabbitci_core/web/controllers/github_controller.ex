defmodule RabbitCICore.GitHubController do
  use RabbitCICore.Web, :controller
  alias RabbitCICore.IncomingWebhooks, as: Webhooks

  # FIXME: Project needs a "github_secret" column first.
  # plug :check_signature

  # Queue a build from the GitHub push payload.
  def create(conn, params) do
    _create(conn, params, get_req_header(conn, "x-github-event"))
  end

  defp _create(conn, params, _event = ["PushEvent"]) do
    case Webhooks.start_build(process_github_payload(params)) do
      {:ok, build} -> json(conn, %{message: "Success!"})
      {:error, error} -> conn |> put_status(:bad_request) |> json(error)
    end
  end
  defp _create(conn, params, [event]), do: _create(conn, params, event)
  defp _create(conn, params, []), do: _create(conn, params, nil)
  defp _create(conn, _, event) do
    conn
    |> put_status(404)
    |> json(%{message: "Event type not supported!", event: event})
  end

  # Converts a map of the GitHub payload to a map with the important parts.
  defp process_github_payload(%{"after" => commit, "ref" => ref,
                                "repository" => %{"clone_url" => repo}}) do
    %{branch: branch_name(ref),
      commit: commit,
      repo: repo}
  end

  # Gets the branch name from the "ref" key on the payload. Example "ref" value
  # "refs/heads/changes" where "changes" is the branch name.
  defp branch_name("refs/heads/" <> name), do: name

  # Plug to check signature from x-hub-signature header. In the format: sha1=...
  defp check_signature(conn, []) do
    signature = get_req_header(conn, "x-hub-signature")
    case _check_signature(signature, conn.private.raw_body) do
      true -> conn
      false ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "Invalid x-hub-signature."})
        |> halt
    end
  end

  # FIXME: Project needs a "github_secret" column first.

  # # Does the actual signature checking.
  # defp _check_signature([a], body), do: _check_signature(a, body)
  # defp _check_signature("sha1=" <> signature, body) do
  #   :crypto.hmac(:sha, <secret goes here>, body)
  #   |> Base.encode16
  #   |> String.upcase == String.upcase(signature)
  # end
  # defp _check_signature(_, _), do: false
end
