defmodule BuildMan.LogProcessor do
  alias BuildMan.LogOutput
  require Logger

  def process(log = %{type: type}) when type in ["stdout", "stderr"] do
    LogOutput.save!(log)
  end

  # Prev is in the format: {fg, bg, attrs} (attrs can be :bright or nil)
  def colors_backwards(text, prev) do
    do_colors(text, {"", prev}, [])
  end

  def colors(text, prev) do
    colors_backwards(text, prev) |> Enum.reverse
  end

  color_values = [{30, :black, :fg},
                  {31, :red, :fg},
                  {32, :green, :fg},
                  {33, :yellow, :fg},
                  {34, :blue, :fg},
                  {35, :magenta, :fg},
                  {36, :cyan, :fg},
                  {37, :white, :fg},
                  {40, :black, :bg},
                  {41, :red, :bg},
                  {42, :green, :bg},
                  {43, :yellow, :bg},
                  {44, :blue, :bg},
                  {45, :magenta, :bg},
                  {46, :cyan, :bg},
                  {47, :white, :bg}]

  defmacrop bright_or_attr(:bright, a), do: :bright
  defmacrop bright_or_attr(_, a), do: a
  defmacrop replace_triplet(current_style, atom, :bg, bright) do
    quote do
      {fg, _bg, attr} = unquote(current_style)
      {fg, unquote(atom), bright_or_attr(unquote(bright), attr)}
    end
  end
  defmacrop replace_triplet(current_style, atom, :fg, bright) do
    quote do
      {_fg, bg, attr} = unquote(current_style)
      {unquote(atom), bg, bright_or_attr(unquote(bright), attr)}
    end
  end

  for {dec, atom, fg_bg} <- color_values do
    for {code, bright} <- [{"\e[0;#{dec}m", nil},
                           {"\e[#{dec}m", nil},
                           {"\e[1;#{dec}m", :bright}] do
      defp do_colors(<<unquote(code) :: utf8, rest :: binary>>,
            current = {_current_text, current_style}, acc) do
        do_colors(
          rest,
          {"", replace_triplet(current_style, unquote(atom), unquote(fg_bg), unquote(bright))},
          append_formatted(current, acc)
        )
      end
    end
  end
  # Reset
  defp do_colors(<<"\e[0m" :: utf8, rest :: binary>>, current, acc) do
    do_colors(rest, {"", {nil, nil, nil}}, append_formatted(current, acc))
  end
  # Bright
  defp do_colors(<<"\e[1m" :: utf8, rest :: binary>>,
        current = {_current_text, {fg, bg, _attrs}}, acc) do
    do_colors(rest, {"", {fg, bg, :bright}}, append_formatted(current, acc))
  end
  defp do_colors("", current, acc) do
    append_formatted(current, acc)
  end
  defp do_colors(<<"<" :: utf8, rest :: binary>>, {current_text, current_colors}, acc) do
    do_colors(rest, {current_text <> "&lt;", current_colors}, acc)
  end
  defp do_colors(<<">" :: utf8, rest :: binary>>, {current_text, current_colors}, acc) do
    do_colors(rest, {current_text <> "&gt;", current_colors}, acc)
  end
  defp do_colors(<<char :: utf8, rest :: binary>>, {current_text, current_colors}, acc) do
    do_colors(rest, {current_text <> <<char>>, current_colors}, acc)
  end

  defp append_formatted({"", _}, acc), do: acc
  defp append_formatted(other, acc), do: [other | acc]
end
