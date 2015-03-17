defmodule Rabbitci.Build do
  use Rabbitci.Web, :model

  schema "builds" do
    field :build_number, :integer
    field :start_time, Ecto.DateTime
    field :finish_time, Ecto.DateTime

    belongs_to :branch, Rabbitci.Branch
    has_many :scripts, Rabbitci.Script

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    cast(model, params, ~w(build_number branch_id start_time finish_time), ~w())
  end

  def serialize(model) do
    model
    |> Enum.map(&serialize_param(&1, model))
    |> Enum.delete(nil)
    |> Enum.into(%{})
  end

  defp serialize_param({thing, dt = %Ecto.DateTime{}}) do
    {thing, Ecto.DateTime.to_string(dt)}
  end
  defp serialize_param({:__state__, _}), do: nil
  defp serialize_param({:__struct__, _}), do: nil
  defp serialize_param({:scripts, _}, model) do
    {:script_ids, script_ids(model)}
  end
  defp serialize_param(other, _), do: nil # Explicit. Prevents security holes.

  def script_ids(model) do
    from(s in Rabbitci.Script,
         where: s.build_id == ^model.id,
         select: s.id)
    |> Rabbitci.Repo.all
  end


end
