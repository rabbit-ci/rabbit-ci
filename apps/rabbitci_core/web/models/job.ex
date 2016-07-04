defmodule RabbitCICore.Job do
  use RabbitCICore.Web, :model
  alias RabbitCICore.{Log, Job, Repo, Step}

  schema "jobs" do
    field :status, :string
    field :start_time, Ecto.DateTime
    field :finish_time, Ecto.DateTime
    field :box, :string # TODO Make this required
    field :provider, :string # TODO Make this required
    has_many :logs, Log
    belongs_to :step, Step
    # TODO: artifacts
    timestamps
  end

  @required_fields ~w(status step_id)
  @optional_fields ~w(start_time finish_time box provider)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_inclusion(:status, ["queued", "running", "failed", "finished", "error"])
    |> foreign_key_constraint(:step_id)
    |> validate_format(:box, ~r/^[a-z0-9-_.:@\/]+$/) # TODO: Tests for this
  end

  def log(job) do
    job
    |> assoc(:logs)
    |> order_by([l], asc: l.order)
    |> Repo.all
    |> Enum.map(&Log.html/1)
    |> Enum.join
  end

  # This is for use in BuildMan. You can use it, but you probably
  # shouldn't as it uses job_id instead of a %Job{}.
  def update_status!(job_id, status) do
    Job
    |> Repo.get!(job_id)
    |> Job.changeset(%{status: status})
    |> Repo.update!
  end
end
