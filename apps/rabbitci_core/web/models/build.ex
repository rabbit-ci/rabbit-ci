defmodule RabbitCICore.Build do
  use RabbitCICore.Web, :model
  alias RabbitCICore.Repo
  alias RabbitCICore.Branch
  alias RabbitCICore.Step
  alias RabbitCICore.Build
  alias RabbitCICore.BuildSerializer
  alias RabbitCICore.Endpoint

  def set_build_number(changes) do
    case get_field(changes, :build_number) do
      nil -> do_set_build_number(changes)
      _ -> changes
    end
  end

  defp do_set_build_number(changes) do
    branch_id = get_field(changes, :branch_id)
    query = (from b in Build,
           where: b.branch_id == ^branch_id,
        order_by: [desc: b.build_number],
           limit: 1,
          select: b.build_number
    )

    build_number = (Repo.one(query) || 0) + 1
    put_change(changes, :build_number, build_number)
  end


  schema "builds" do
    field :build_number, :integer
    field :commit, :string
    field :config_extracted, :string, default: "false"

    belongs_to :branch, Branch
    has_many :steps, Step

    timestamps
  end

  @required_params ~w(branch_id commit config_extracted)
  @optional_params ~w(build_number)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_params, @optional_params)
    |> validate_inclusion(:config_extracted, ["false", "true", "error"])
    |> foreign_key_constraint(:branch_id)
    |> unique_constraint(:build_number, name: :builds_branch_id_build_number_index)
    |> prepare_changes(&set_build_number/1)
  end

  def status([]), do: "queued"
  def status(statuses) when is_list(statuses) do
    cond do
      Enum.any?(statuses, fn(s) -> s == "failed" end) -> "failed"
      Enum.any?(statuses, fn(s) -> s == "error" end) -> "error"
      Enum.any?(statuses, fn(s) -> s == "running" end) -> "running"
      Enum.any?(statuses, fn(s) -> s == "finished" end) &&
        Enum.any?(statuses, fn(s) -> s == "queued" end) -> "running"
      Enum.all?(statuses, fn(s) -> s == "queued" end) -> "queued"
      Enum.all?(statuses, fn(s) -> s == "finished" end) -> "finished"
    end
  end
  def status(%Build{config_extracted: "error"}), do: "error"
  def status(build) do
    Repo.preload(build, :steps).steps
    |> Enum.map(&(&1.status))
    |> status
  end

  def json_from_id!(build_id) do
    build_id
    |> json_from_id_query
    |> Repo.one!
    |> BuildSerializer.format(Endpoint, %{})
  end

  defp json_from_id_query(build_id) do
        from b in Build,
       join: br in assoc(b, :branch),
       join: p in assoc(br, :project),
      where: b.id == ^build_id,
    preload: [branch: {br, project: p}]
  end

  def get_repo_from_id!(build_id) do
    build_id
    |> repo_from_id_query
    |> Repo.one!
  end

  defp repo_from_id_query(build_id) do
        from b in Build,
       join: br in assoc(b, :branch),
       join: p in assoc(br, :project),
      where: b.id == ^build_id,
     select: p.repo
  end
end
