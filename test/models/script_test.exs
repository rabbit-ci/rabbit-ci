defmodule Rabbitci.ScriptTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Script

  test "required fields" do
    assert !Script.changeset(%Script{}, %{name: "xyz"}).valid?
    assert !Script.changeset(%Script{}, %{status: "xyz"}).valid?
    assert !Script.changeset(%Script{}, %{name: "xyz", status: "xyz"}).valid?
    assert Script.changeset(%Script{}, %{name: "xyz", status: "xyz",
                                         build_id: 0}).valid?
  end
end
