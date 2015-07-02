defmodule RabbitCICore.ScriptTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Script

  test "required fields" do
    assert !Script.changeset(%Script{}, %{name: "xyz"}).valid?
    assert !Script.changeset(%Script{}, %{status: "xyz"}).valid?
    assert !Script.changeset(%Script{}, %{name: "xyz", status: "xyz"}).valid?
    assert Script.changeset(%Script{}, %{name: "xyz", status: "xyz",
                                         build_id: 0}).valid?
  end
end
