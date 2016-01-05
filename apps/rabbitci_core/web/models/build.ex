defmodule RabbitCICore.Build do
  use RabbitCICore.Web, :model
  alias RabbitCICore.Repo
  alias RabbitCICore.Branch
  alias RabbitCICore.Step
  alias RabbitCICore.Build
  alias RabbitCICore.BuildSerializer
  alias RabbitCICore.Endpoint

  before_insert :set_build_number

  def set_build_number(changeset) do
    branch_id = Ecto.Changeset.get_field(changeset, :branch_id)
    query = (from b in Build,
           where: b.branch_id == ^branch_id,
        order_by: [desc: b.build_number],
           limit: 1,
          select: b.build_number
    )

    build_number = (Repo.one(query) || 0) + 1
    Ecto.Changeset.change(changeset, %{build_number: build_number})
  end

  schema "builds" do
    field :build_number, :integer
    field :start_time, Ecto.DateTime
    field :finish_time, Ecto.DateTime
    field :commit, :string
    field :config_extracted, :string, default: "false"

    belongs_to :branch, Branch
    has_many :steps, Step

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    cast(model, params, ~w(branch_id commit config_extracted),
         ~w(start_time build_number finish_time))
    |> validate_inclusion(:config_extracted, ["false", "true", "error"])
    |> foreign_key_constraint(:branch_id)
  end

  def status([]), do: "queued"
  def status(statuses) when is_list(statuses) do
    cond do
      Enum.any?(statuses, fn(status) -> status == "failed" end) -> "failed"
      Enum.any?(statuses, fn(status) -> status == "error" end) -> "error"
      Enum.any?(statuses, fn(status) -> status == "running" end) -> "running"
      Enum.any?(statuses, fn(status) -> status == "finished" end) &&
        Enum.any?(statuses, fn(status) -> status == "queued" end) -> "running"
      Enum.all?(statuses, fn(status) -> status == "queued" end) -> "queued"
      Enum.all?(statuses, fn(status) -> status == "finished" end) -> "finished"
    end
  end
  def status(%Build{config_extracted: "error"}), do: "error"
  def status(build) do
    Repo.preload(build, :steps).steps
    |> Enum.map(&(&1.status))
    |> status
  end

  def json_from_id!(build_id) do
    import Ecto.Query, only: [from: 1, from: 2]

    (from b in Build,
     join: br in assoc(b, :branch),
     join: p in assoc(br, :project),
     where: b.id == ^build_id,
     preload: [branch: {br, project: p}])
    |> Repo.one!
    |> BuildSerializer.format(Endpoint, %{})
  end
end
