defmodule Rabbitci.Build do
  use Rabbitci.Web, :model

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
    |> validate_unique_with_scope(:build_number, [scope: :branch_id])

    # Build numbers are scoped on the branch. IE each branch counts
    # builds separately. This is to prevent the confusion of Branch A
    # having builds 1, 2, and 4 because Branch B took build 3.
  end

  def script_ids(record) do
    from(s in Rabbitci.Script,
         where: s.build_id == ^record.id,
         select: s.id)
    |> Rabbitci.Repo.all
  end

  def latest_build_on_branch(branch = %Rabbitci.Branch{}) do
    query = (from b in Rabbitci.Build,
             where: b.branch_id == ^branch.id,
             # select: b.build_number,
             limit: 1,
             order_by: [desc: b.build_number])

    Rabbitci.Repo.one(query)
  end
end
