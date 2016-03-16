defmodule RabbitCICore.Factory do
  use ExMachina.Ecto, repo: RabbitCICore.EctoRepo

  alias RabbitCICore.{Project, Branch, Build, Step, Log}

  def factory(:project) do
    %Project{
      name: sequence(:name, &"my/#{&1}project"),
      repo: sequence(:repo, &"my#{&1}@repo.git")
    }
  end

  def factory(:branch) do
    %Branch{
      name: sequence(:name, &"my#{&1}branch"),
      project: build(:project)
    }
  end

  def factory(:build) do
    %Build{
      commit: "abc",
      branch: build(:branch),
      # Temporary fix. See thoughtbot/ex_machina#78
      build_number: sequence(:build_number, fn(x) -> x end)
    }
  end

  def factory(:step) do
    %Step{
      name: sequence(:name, &"my#{&1}step"),
      build: build(:build)
    }
  end

  def factory(:log) do
    %Log{
      order: sequence(:order, &(&1)),
      stdio: sequence(:stdio, &"log output line: #{&1}"),
      type: "stdout",
      step: build(:step)
    }
  end
end
