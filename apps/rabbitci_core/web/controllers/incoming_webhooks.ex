defmodule RabbitCICore.IncomingWebhooks do
  import Ecto.Query
  alias RabbitCICore.Build
  alias RabbitCICore.Branch
  alias RabbitCICore.Project
  alias RabbitCICore.Repo

  @exchange Application.get_env(:rabbitci_core, :config_extraction_exchange,
                                "fake_exchange")

  # Repo, commit, pr #, branch name.
  def start_build(p = %{name: _, commit: _, pr: _, branch: _}) do
    case find_branch(Dict.take(p, [:branch, :name])) do
      {:ok, branch} -> _start_build(branch, p)
      e = {:error, _} -> e
    end
  end
  def start_build(p = %{name: _, commit: _, branch: _}) do
    start_build(Map.merge(p, %{pr: nil}))
  end

  defp _start_build(branch, %{name: name, commit: commit, pr: pr}) do
    changeset =
      Ecto.Model.build(branch, :builds)
      |> Build.changeset(%{commit: commit})

    case Repo.insert(changeset) do
      {:ok, build} ->
        add = pr && %{pr: pr} || %{commit: commit}

        repo = Repo.preload(branch, :project).project.repo
        config =
          Map.merge(%{name: name, repo: repo, build_id: build.id}, add)
        |> :erlang.term_to_binary

        RabbitMQ.publish(@exchange, "", config)
        {:ok, build}
      {:error, changeset} -> {:error, Map.take(changeset, [:errors])}
    end
  end

  defp find_branch(%{branch: branch_name, name: name}) do
    query = (
      from br in Branch,
      join: p in Project,
      on: br.project_id == p.id,
      where: br.name == ^branch_name
      and p.name == ^name
    )

    case Repo.one(query) do
      nil -> create_branch(branch_name, name)
      branch -> {:ok, branch}
    end
  end

  defp create_branch(branch_name, name) do
    case do_create_branch(branch_name, name) do
      {:ok, branch} -> {:ok, branch}
      {:error, map} -> {:error, Map.take(map, [:errors])}
    end
  end

  defp do_create_branch(branch_name, name) do
    case Repo.get_by(Project, name: name) do
      nil -> {:error, %{errors: "No project"}}
      project ->
        Ecto.Model.build(project, :branches)
        |> Branch.changeset(%{name: branch_name})
        |> Repo.insert
    end
  end
end
