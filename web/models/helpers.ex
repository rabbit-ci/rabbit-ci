defmodule Rabbitci.ModelHelpers do
  import Ecto.Query

  def validate_unique_with_scope(%{model: model, params: params} = changeset, field, opts)
  when is_list(opts) do
    scope = Keyword.fetch!(opts, :scope)
    scope_value = Map.get(params, Atom.to_string(scope)) || Map.get(model, scope)

    Ecto.Changeset.validate_change changeset, field, :unique, fn _, value ->
      struct = model.__struct__

      query =(from m in struct,
              select: field(m, ^field),
              limit: 1,
              where: field(m, ^scope) == ^scope_value)

      query =
        if opts[:downcase] do
          from m in query, where:
            fragment("lower(?)", field(m, ^field)) == fragment("lower(?)", ^value)
        else
          from m in query, where: field(m, ^field) == ^value
        end

      if pk_value = Ecto.Model.primary_key(model) do
        pk_field = struct.__schema__(:primary_key)
        query = from m in query,
                where: field(m, ^pk_field) != ^pk_value
      end

      case Rabbitci.Repo.all(query) do
        []  -> []
        [_] -> [{field, :unique}]
      end
    end
  end
end
