defmodule RabbitCICore.GitHubController do
  use RabbitCICore.Web, :controller
  alias RabbitCICore.IncomingWebhooks, as: Webhooks
  alias RabbitCICore.Project

  plug :process_github_payload
  plug :load_project
  plug :check_signature

  # Queue a build from the GitHub push payload.
  def create(conn, params) do
    _create(conn, params, get_req_header(conn, "x-github-event"))
  end

  defp _create(conn, params, _event = ["PushEvent"]) do
    case Webhooks.start_build(conn.assigns.fixed_params) do
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
  defp process_github_payload(conn = %{params:
                                       %{"after" => commit,
                                         "ref" => ref,
                                         "repository" =>
                                           %{"clone_url" => repo}}}, []) do
    assign(conn, :fixed_params, %{branch: branch_name(ref),
                                  commit: commit,
                                  repo: repo})
  end

  # Gets the branch name from the "ref" key on the payload. Example "ref" value
  # "refs/heads/changes" where "changes" is the branch name.
  defp branch_name("refs/heads/" <> name), do: name

  defp load_project(conn = %{assigns:
                             %{fixed_params: %{repo: repo}}}, []) do
    assign(conn, :project, Repo.get_by!(Project, repo: repo))
  end

  # Plug to check signature from x-hub-signature header. In the format: sha1=...
  defp check_signature(conn = %{assigns:
                                %{project:
                                  %Project{webhook_secret: secret}}}, []) do
    signature = get_req_header(conn, "x-hub-signature")
    case do_check_signature(signature, conn.private.raw_body, secret) do
      true -> conn
      false ->
        conn
        |> put_status(:unauthorized)
        |> json(%{message: "Invalid x-hub-signature."})
        |> halt
    end
  end

  # Does the actual signature checking.
  # If a secret has not been set, we do not allow access.
  defp do_check_signature(_, _, nil), do: false
  defp do_check_signature("sha1=" <> signature, body, secret) do
    :crypto.hmac(:sha, secret, body)
    |> Base.encode16
    |> String.upcase == String.upcase(signature)
  end
  defp do_check_signature([a], b, s), do: do_check_signature(a, b, s)
  defp do_check_signature(_, _, _), do: false
end
