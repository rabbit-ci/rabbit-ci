defmodule RabbitCICore.GitHubController do
  use RabbitCICore.Web, :controller
  alias RabbitCICore.IncomingWebhooks, as: Webhooks
  alias RabbitCICore.Project

  @push_event "push"
  @pull_request_event "pull_request"

  plug :check_event_type, [@push_event, @pull_request_event]
  plug :process_github_payload
  plug :load_project
  plug :check_signature

  # Queue a build from the GitHub push payload.
  def create(conn, params) do
    _create(conn, params, conn.assigns.event)
  end

  defp _create(conn, _params, event)
  when event in [@push_event, @pull_request_event] do
    case Webhooks.start_build(conn.assigns.fixed_params) do
      {:ok, build} ->
        conn
        |> assign(:build, build)
        |> render
      {:error, error} -> conn |> put_status(:bad_request) |> json(error)
    end
  end

  defp check_event_type(conn, types) do
    event = hd get_req_header(conn, "x-github-event")
    case event in types do
      true -> conn |> assign(:event, event)
      # 200 OK because this isn't really an error. GitHub will think this was a
      # failure if we return anything non 2XX.
      _ -> json(conn, %{message: "Event type not supported!"})
    end
  end


  # Converts a map of the GitHub payload to a map with the important parts.
  defp process_github_payload(conn = %{assigns: %{event: event}}, []) do
    _process_github_payload(conn, event)
  end
  defp _process_github_payload(conn = %{params:
                                        %{"after" => commit,
                                          "ref" => ref,
                                          "repository" =>
                                            %{"full_name" => name}}},
                               @push_event) do
    assign(conn, :fixed_params, %{branch: branch_name(ref),
                                  commit: commit,
                                  name: name})
  end
  defp _process_github_payload(conn = %{params:
                                        %{"action" => action,
                                          "number" => number,
                                          "pull_request" =>
                                            %{"head" =>
                                               %{"sha" => commit,
                                                 "ref" => branch}},
                                          "repository" =>
                                            %{"full_name" => name}}},
                               @pull_request_event)
  when action in ["opened", "synchronize"] do
    assign(conn, :fixed_params, %{pr: number,
                                  branch: branch,
                                  commit: commit,
                                  name: name})
  end

  # Gets the branch name from the "ref" key on the payload. Example "ref" value
  # "refs/heads/changes" where "changes" is the branch name.
  defp branch_name("refs/heads/" <> name), do: name

  defp load_project(conn = %{assigns:
                             %{fixed_params: %{name: name}}}, []) do
    assign(conn, :project, Repo.get_by!(Project, name: name))
  end

  # Plug to check signature from x-hub-signature header. In the format: sha1=...
  defp check_signature(conn = %{assigns:
                                %{project:
                                  %Project{webhook_secret: secret}}}, []) do
    signature = get_req_header(conn, "x-hub-signature")
    if do_check_signature(signature, conn.private.raw_body, secret) do
      conn
    else
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
    :sha
    |> :crypto.hmac(secret, body)
    |> Base.encode16
    |> String.upcase == String.upcase(signature)
  end
  defp do_check_signature([a], b, s), do: do_check_signature(a, b, s)
  defp do_check_signature(_, _, _), do: false
end
