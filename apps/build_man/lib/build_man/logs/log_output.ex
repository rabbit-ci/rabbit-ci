defmodule BuildMan.LogOutput do
  alias BuildMan.LogOutput
  alias RabbitCICore.Repo
  alias RabbitCICore.Log
  alias RabbitCICore.RecordPubSubChannel, as: PubSub

  defstruct order: nil, text: "", type: "stdout", job_id: -1, colors: {nil, nil, nil}

  def save!(%LogOutput{job_id: job_id,
                       text: text,
                       order: order,
                       type: type,
                       colors: {fg, bg, style}}) do
    %Log{}
    |> Log.changeset(
      %{stdio: text,
        order: order,
        type: type,
        fg: to_string(fg),
        bg: to_string(bg),
        style: to_string(style),
        job_id: job_id}
    )
    |> Repo.insert!(log: false)
    |> PubSub.new_log
  end
end
