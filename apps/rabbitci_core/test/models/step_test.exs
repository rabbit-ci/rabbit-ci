defmodule RabbitCICore.StepTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Step

  test "required fields" do
    assert !Step.changeset(%Step{}, %{name: "xyz"}).valid?
    assert !Step.changeset(%Step{}, %{status: "xyz"}).valid?
    assert !Step.changeset(%Step{}, %{name: "xyz", status: "xyz"}).valid?
    assert Step.changeset(%Step{}, %{name: "xyz", status: "xyz",
                                         build_id: 0}).valid?
  end
end
