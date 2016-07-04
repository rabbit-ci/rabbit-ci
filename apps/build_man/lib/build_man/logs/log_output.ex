defmodule BuildMan.LogOutput do
  alias BuildMan.LogOutput
  alias RabbitCICore.Repo
  alias RabbitCICore.Job
  alias RabbitCICore.Log

  defstruct order: nil, text: "", type: "stdout", job_id: -1, colors: {nil, nil, nil}

  def save!(%LogOutput{job_id: job_id,
                       text: text,
                       order: order,
                       type: type,
                       colors: {fg, bg, style}}) do
    Repo.get!(Job, job_id, log: false)
    |> Ecto.build_assoc(:logs)
    |> Log.changeset(%{stdio: text,
                      order: order,
                      type: type,
                      fg: to_string(fg),
                      bg: to_string(bg),
                      style: to_string(style)})
    |> Repo.insert!(log: false)
  end
end
