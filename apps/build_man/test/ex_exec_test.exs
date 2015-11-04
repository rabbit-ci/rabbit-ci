defmodule ExExecTest do
  use ExUnit.Case
  setup_all do
    ExExec.start
    :ok
  end
  doctest ExExec
end
