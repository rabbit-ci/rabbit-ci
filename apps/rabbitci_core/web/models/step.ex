defmodule RabbitCICore.Step do
  use RabbitCICore.Web, :model
  alias RabbitCICore.Log
  alias RabbitCICore.Build
  alias RabbitCICore.Log
  alias RabbitCICore.Repo
  alias RabbitCICore.Step

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

  def log(_step, _clean \\ :clean)
  def log(step, :clean), do: clean_log log(step, :no_clean)
  def log(step, :html) do
    log_str = log(step, :no_clean)
    aha = System.find_executable("aha")
    {:ok, path} = BuildMan.FileHelpers.unique_folder("aha")
    inpath = Path.join([path, "input-file.txt"])
    {:ok, _, aha_pid} =
      ExExec.run([aha | ["--no-header", "--stylesheet", "--black"]],
                 [{:stdin, to_char_list inpath}, :stdout, :monitor])
    File.write!(inpath, log_str)
    html_str = agg_output("")
    File.rm_rf!(path)
    html_str
  end
  def log(step, :no_clean) do
    from(l in assoc(step, :logs),
         order_by: [asc: l.order],
         select: l.stdio)
    |> Repo.all
    |> Enum.join
  end

  defp agg_output(acc) do
    html_str = receive do
      {:stdout, _pid, body} -> agg_output(acc <> body)
      {:DOWN, _, :process, _, :normal} -> acc
    after 200 -> :timeout
    end
  end


  def clean_log(raw_log) do
    Regex.replace(~r/\x1b(\[[0-9;]*[mK])?/, raw_log, "")
  end

  # This is for use in BuildMan.Vagrant. You can use it, but you probably
  # shouldn't as it uses step_id instead of a %Step{}.
  def update_status!(step_id, status) do
    Repo.get!(Step, step_id)
    |> Step.changeset(%{status: status})
    |> Repo.update!
  end
end
