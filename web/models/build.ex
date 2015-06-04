defmodule Rabbitci.Build do
  use Rabbitci.Web, :model

  alias Rabbitci.Repo

  schema "builds" do
    field :build_number, :integer

    field :start_time, Ecto.DateTime
    field :finish_time, Ecto.DateTime
    field :commit, :string

    belongs_to :branch, Rabbitci.Branch
    has_many :scripts, Rabbitci.Script
    has_one :config_file, Rabbitci.ConfigFile

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    cast(model, params, ~w(build_number branch_id commit),
         ~w(start_time finish_time))
    |> validate_unique(:build_number, scope: [:branch_id], on: Repo)

    # Build numbers are scoped on the branch. i.e. each branch counts
    # builds separately. This is to prevent the confusion of Branch A
    # having builds 1, 2, and 4 because Branch B took build 3.
  end

  def script_ids(record) do
    from(s in Rabbitci.Script,
         where: s.build_id == ^record.id,
         select: s.id)
    |> Rabbitci.Repo.all
  end

  def status(statuses) when is_list(statuses) do
    cond do
      Enum.any?(statuses, fn(status) -> status == "failed" end) -> "failed"
      Enum.any?(statuses, fn(status) -> status == "error" end) -> "error"
      Enum.any?(statuses, fn(status) -> status == "running" end) -> "running"
      Enum.any?(statuses, fn(status) -> status == "finished" end) &&
        Enum.any?(statuses, fn(status) -> status == "queued" end) -> "running"
      Enum.all?(statuses, fn(status) -> status == "queued" end) -> "queued"
      Enum.all?(statuses, fn(status) -> status == "finished" end) -> "finished"
      [] -> "queued"
    end
  end

  def status(build) do
    build = Repo.preload(build, :scripts)
    Enum.map(build.scripts, &(&1.status)) |> status
  end

  def latest_build_on_branch(branch = %Rabbitci.Branch{}) do
    query = (from b in Rabbitci.Build,
             where: b.branch_id == ^branch.id,
             limit: 1,
             order_by: [desc: b.build_number])

    Rabbitci.Repo.one(query)
  end
end
