defmodule RabbitCICore.Job do
  use RabbitCICore.Web, :model
  alias RabbitCICore.{Log, Build, Job, Repo}

  schema "jobs" do
    field :status, :string
    field :name, :string
    field :start_time, Ecto.DateTime
    field :finish_time, Ecto.DateTime
    has_many :logs, Log
    # TODO: artifacts
    belongs_to :build, Build
    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, ~w(build_id name status), ~w(start_time finish_time))
    |> validate_inclusion(:status, ["queued", "running", "failed", "finished", "error"])
    |> foreign_key_constraint(:build_id)
  end

  def log(job, clean \\ :clean)
  def log(job, :clean), do: clean_log log(job, :no_clean)
  def log(job, :no_clean) do
    job
    |> assoc(:logs)
    |> order_by([l], asc: l.order)
    |> select([l], l.stdio)
    |> Repo.all
    |> Enum.join
  end

  def clean_log(raw_log) do
    Regex.replace(~r/\x1b(\[[0-9;]*[mK])?/, raw_log, "")
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
