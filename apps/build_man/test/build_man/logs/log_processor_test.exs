defmodule BuildMan.LogProcessorTest do
  use ExUnit.Case
  alias BuildMan.LogProcessor

  test "colors_backwards/2 should extract color information" do
    text =
      IO.ANSI.format([:red, "foobar",
                      :bright, "foobar",
                      :blue, "foobar",
                      :green_background, "foobar"], true)
      |> to_string
    assert LogProcessor.colors(text, {nil, nil, nil}) ==
      [{"foobar", {:red, nil, nil}},
       {"foobar", {:red, nil, :bright}},
       {"foobar", {:blue, nil, :bright}},
       {"foobar", {:blue, :green, :bright}}]
  end

  test "colors_backwards/2 should support ^[1;#m syntax" do
    assert LogProcessor.colors("\e[1;33mfoobar", {nil, nil, nil}) ==
      [{"foobar", {:yellow, nil, :bright}}]
  end

end
