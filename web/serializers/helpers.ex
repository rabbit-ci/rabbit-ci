defmodule Rabbitci.SerializerHelpers do
  defmacro time(name, model) do
    name = Macro.to_string(name) |> String.to_atom
    quote do
      def unquote(name)(%{:__struct__ => unquote(model), unquote(name) => nil}),
      do: nil
      def unquote(name)(r), do: Ecto.DateTime.to_string(r.unquote(name))
    end
  end
end
