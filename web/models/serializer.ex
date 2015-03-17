defmodule Rabbitci.Serializer do
  defmacro serialize(do: {_, _, [{:attributes, _, attrs},
                                 {:custom, _, [[do: custom]]}]}) do

    gen_values =
    (for attr <- attrs do
       [thing] = quote do
         {unquote(attr), value} -> {unquote(attr), value}
       end
       thing
    end)

    default = quote do {_, _} -> nil end

    quote do
      def serialize(model) do
        for param <- model do
          case param do
            unquote(custom ++ gen_values ++ default)
          end
        end
        |> List.delete(nil)
        |> Enum.into(%{})
      end
    end
  end
end
