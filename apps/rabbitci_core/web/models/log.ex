defmodule RabbitCICore.Log do
  use RabbitCICore.Web, :model
  alias RabbitCICore.{Job, Log}

  schema "logs" do
    field :stdio, :string
    field :order, :integer
    field :type, :string
    field :fg, :string, default: ""
    field :bg, :string, default: ""
    field :style, :string, default: ""

    belongs_to :job, Job

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, ~w(job_id stdio type order), ~w(fg bg style))
    |> validate_inclusion(:type, ["stdout", "stderr"])
    |> foreign_key_constraint(:job_id)
  end

  def html(%Log{stdio: stdio, fg: fg, bg: bg, style: style}) do
    "<span class='#{html_class(fg, bg, style)}'>#{stdio}</span>"
  end

  defp html_class(fg, "", style), do: "ansi #{fg} #{style}"
  defp html_class(fg, bg, style), do: "ansi #{fg} #{bg}-bg #{style}"
end
