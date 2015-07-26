defmodule RabbitCICore.ConfigFile do
  use RabbitCICore.Web, :model

  alias RabbitCICore.Build

  schema "config_files" do
    field :raw_body, :string

    belongs_to :build, Build

    timestamps
  end

  @required_fields ~w(raw_body build_id)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If `params` are nil, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ nil) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_change :raw_body, fn
      :raw_body, body ->
        case Poison.decode(body) do
          {:ok, %{"scripts" => [_ | _]}} ->
            []
          {:ok, _} ->
            [{:raw_body, :missing_fields}]
          _ ->
            [{:raw_body, :json_invalid}]
        end
    end
  end
end
