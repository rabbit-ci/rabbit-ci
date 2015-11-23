defmodule RabbitCICore.Step do
  use RabbitCICore.Web, :model
  alias RabbitCICore.Log
  alias RabbitCICore.Build
  alias RabbitCICore.Step
  alias RabbitCICore.Log
  alias RabbitCICore.Repo

  schema "steps" do
    field :status, :string
    field :name, :string
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
    cast(model, params, ~w(build_id name status), ~w())
    |> validate_inclusion(:status, ["queued", "running", "failed", "finished"])
  end

  def log(step) do
    raw_log =
      Repo.preload(step, :logs).logs
    |> Enum.map(&(&1.stdio))
    |> Enum.join
    |> clean_log
  end

  defp clean_log(raw_log) do
    Regex.replace(~r/\x1b(\[[0-9;]*[mK])?/, raw_log, "")
  end
end
