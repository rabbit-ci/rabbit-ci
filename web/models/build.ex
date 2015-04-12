defmodule Rabbitci.Build do
  use Rabbitci.Web, :model

  schema "builds" do
    field :build_number, :integer
    field :start_time, Ecto.DateTime
    field :finish_time, Ecto.DateTime

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
    cast(model, params, ~w(build_number branch_id),
         ~w(start_time finish_time))
    |> validate_unique_with_scope(:build_number, [scope: :branch_id])
  end

  def script_ids(record) do
    from(s in Rabbitci.Script,
         where: s.build_id == ^record.id,
         select: s.id)
    |> Rabbitci.Repo.all
  end


end
