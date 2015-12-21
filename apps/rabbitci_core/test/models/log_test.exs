defmodule RabbitCICore.LogTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Log

  test "required fields" do
    refute Log.changeset(%Log{}, %{}).valid?
    refute Log.changeset(%Log{}, %{stdio: "xyz"}).valid?
    refute Log.changeset(%Log{}, %{stdio: nil, step_id: 0}).valid?
    refute Log.changeset(%Log{}, %{stdio: "xyz", step_id: 0}).valid?
    refute Log.changeset(%Log{},
                         %{stdio: "xyz", step_id: 0,
                           order: 0, type: "thingy"}).valid?
    assert Log.changeset(%Log{},
                         %{stdio: "xyz", step_id: 0,
                           order: 0, type: "stderr"}).valid?
    assert Log.changeset(%Log{},
                         %{stdio: "xyz", step_id: 0,
                           order: 0, type: "stdout"}).valid?
  end
end
