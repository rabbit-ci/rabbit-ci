defmodule RabbitCICore.Repo do
  alias RabbitCICore.EctoRepo
  alias RabbitCICore.{Build, Step, Log}
  alias RabbitCICore.{BranchUpdaterChannel, BuildUpdaterChannel,
                      StepUpdaterChannel}

  # Delgate most stuff to EctoRepo
  def config(), do: EctoRepo.config()
  def transaction(opts \\ [], fun), do: EctoRepo.transaction(opts, fun)
  def rollback(value), do: EctoRepo.rollback(value)
  def all(queryable, opts \\ []), do: EctoRepo.all(queryable, opts)
  def get(queryable, id, opts \\ []), do: EctoRepo.get(queryable, id, opts)
  def get!(queryable, id, opts \\ []), do: EctoRepo.get!(queryable, id, opts)
  def get_by(queryable, clauses, opts \\ []), do: EctoRepo.get_by(queryable, clauses, opts)
  def get_by!(queryable, clauses, opts \\ []), do: EctoRepo.get_by!(queryable, clauses, opts)
  def one(queryable, opts \\ []), do: EctoRepo.one(queryable, opts)
  def one!(queryable, opts \\ []), do: EctoRepo.one!(queryable, opts)
  def insert_all(schema, entries, opts \\ []), do: EctoRepo.insert_all(schema, entries, opts)
  def update_all(queryable, updates, opts \\ []), do: EctoRepo.update_all(queryable, updates, opts)
  def delete_all(queryable, opts \\ []), do: EctoRepo.delete_all(queryable, opts)
  def insert_or_update(changeset, opts \\ []), do: EctoRepo.insert_or_update(changeset, opts)
  def insert_or_update!(changeset, opts \\ []), do: EctoRepo.insert_or_update!(changeset, opts)
  def delete(struct, opts \\ []), do: EctoRepo.delete(struct, opts)
  def delete!(struct, opts \\ []), do: EctoRepo.delete!(struct, opts)
  def preload(struct_or_structs, preloads), do: EctoRepo.preload(struct_or_structs, preloads)
  def log(entry), do: EctoRepo.log(entry)

  # Custom functions
  def insert(queryable, opts \\ []) do
    handle_repo_return EctoRepo.insert(queryable, opts), :insert
  end

  def insert!(queryable, opts \\ []) do
    model = EctoRepo.insert!(queryable, opts)
    model_event(model, :insert)
    model
  end

  def update(queryable, opts \\ []) do
    handle_repo_return EctoRepo.update(queryable, opts), :update
  end

  def update!(queryable, opts \\ []) do
    model = EctoRepo.update!(queryable, opts)
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
