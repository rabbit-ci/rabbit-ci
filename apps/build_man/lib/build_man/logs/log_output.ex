defmodule BuildMan.LogOutput do
  alias BuildMan.LogOutput
  alias RabbitCICore.Repo
  alias RabbitCICore.Job
  alias RabbitCICore.Log

  defstruct order: nil, text: "", type: "stdout", job_id: -1

  def save!(%LogOutput{job_id: job_id,
                       text: text,
                       order: order,
                       type: type}) do
    Repo.get!(Job, job_id, log: false)
    |> Ecto.Model.build(:logs)
    |> Log.changeset(%{stdio: text, order: order, type: type})
    |> Repo.insert!(log: false)
  end
end
