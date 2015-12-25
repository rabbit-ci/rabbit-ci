defmodule RabbitCICore.Repo do
  use Ecto.Repo, otp_app: :rabbitci_core
  defoverridable [insert: 2, insert!: 2, update: 2, update!: 2]

  alias RabbitCICore.{Build, Step, Log}
  alias RabbitCICore.{BranchUpdaterChannel, BuildUpdaterChannel,
                      StepUpdaterChannel}

  def insert(queryable, opts \\ []) do
    handle_repo_return super(queryable, opts), :insert
  end

  def insert!(queryable, opts \\ []) do
    model = super(queryable, opts)
    model_event(model, :insert)
    model
  end

  def update(queryable, opts \\ []) do
    handle_repo_return super(queryable, opts), :update
  end

  def update!(queryable, opts \\ []) do
    model = super(queryable, opts)
    model_event(model, :update)
    model
  end

  defp handle_repo_return(return, type) do
    case return do
      {:ok, model} = good ->
        model_event(model, type)
        good
      otherwise -> otherwise
    end
  end

  defp model_event(%Log{} = model, :insert) do
    payload = %{log_append: model.stdio, step_id: model.step_id}
    StepUpdaterChannel.publish_log(model.step_id, payload)
  end
  defp model_event(%Step{} = model, :insert) do
    BuildUpdaterChannel.update_build(model.build_id)
  end
  defp model_event(%Step{} = model, :update) do
    BuildUpdaterChannel.update_build(model.build_id)
  end
  defp model_event(%Build{} = model, :insert) do
    BranchUpdaterChannel.new_build(model.branch_id, model.id)
  end
  defp model_event(%Build{} = model, :update) do
    BuildUpdaterChannel.update_build(model.id)
  end
  defp model_event(_model, :update), do: :nothing
  defp model_event(_model, :insert), do: :nothing
end
