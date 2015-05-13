defmodule Rabbitci.LogTest do
  use Rabbitci.Integration.Case
  use Rabbitci.TestHelper

  alias Rabbitci.Log

  test "required fields" do
    assert !Log.changeset(%Log{}, %{}).valid?
    assert !Log.changeset(%Log{}, %{stdio: "xyz"}).valid?
    assert !Log.changeset(%Log{}, %{stdio: nil, script_id: 0}).valid?
    assert Log.changeset(%Log{}, %{stdio: "xyz", script_id: 0}).valid?
  end
end
