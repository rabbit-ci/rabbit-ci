defmodule RabbitCICore.Log do
  use RabbitCICore.Web, :model
  alias RabbitCICore.Step
  alias RabbitCICore.Repo
  alias RabbitCICore.StepUpdaterChannel

  after_insert :notify_chan

  def notify_chan(changeset) do
    id = changeset.model.step_id
    payload = %{log_append: changeset.model.stdio, step_id: id}
    StepUpdaterChannel.publish_log(id, payload)
    changeset
  end

  schema "logs" do
    field :stdio, :string
    field :order, :integer
    field :type, :string

    belongs_to :step, Step

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    cast(model, params, ~w(stdio step_id type order), ~w())
    |> validate_inclusion(:type, ["stdout", "stderr"])
  end
end
