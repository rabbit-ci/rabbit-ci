defmodule RabbitCICore.StepSerializer do
  use JaSerializer
  alias RabbitCICore.Repo
  alias RabbitCICore.Step
  alias RabbitCICore.BuildSerializer

  attributes [:name, :status, :log]

  def type, do: "steps"
  def log(r, _), do: Step.log(r)
end
