defmodule RabbitCICore.StepTest do
  use RabbitCICore.Integration.Case
  use RabbitCICore.TestHelper

  alias RabbitCICore.Step

  test "required fields" do
    assert !Step.changeset(%Step{}, %{name: "queued"}).valid?
    assert !Step.changeset(%Step{}, %{status: "queued"}).valid?
    assert !Step.changeset(%Step{}, %{name: "xyz", status: "queued"}).valid?
    assert Step.changeset(%Step{}, %{name: "xyz", status: "queued",
                                         build_id: 0}).valid?
  end
end
