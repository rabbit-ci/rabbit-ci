defmodule BuildMan.LogOutput do
  alias BuildMan.LogOutput
  alias RabbitCICore.Repo
  alias RabbitCICore.Step
  alias RabbitCICore.Log

  defstruct order: nil, text: "", type: "stdout", step_id: -1

  def save!(%LogOutput{step_id: step_id,
                       text: text,
                       order: order,
                       type: type}) do
    Repo.get!(Step, step_id, log: false)
    |> Ecto.Model.build(:logs)
    |> Log.changeset(%{stdio: text, order: order, type: type})
    |> Repo.insert!(log: false)
  end
end
