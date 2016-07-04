defmodule RabbitCICore.Factory do
  use ExMachina.Ecto, repo: RabbitCICore.Repo

  alias RabbitCICore.{Project, Branch, Build, Job, Log, Step}

  def project_factory do
    %Project{
      name: sequence(:name, &"my/#{&1}project"),
      repo: sequence(:repo, &"my#{&1}@repo.git")
    }
  end

  def branch_factory do
    %Branch{
      name: sequence(:name, &"my#{&1}branch"),
      project: build(:project)
    }
  end

  def build_factory do
    %Build{
      commit: "abc",
      branch: build(:branch),
      # Temporary fix. See thoughtbot/ex_machina#78
      build_number: sequence(:build_number, fn(x) -> x end)
    }
  end

  def job_factory do
    %Job{
      step: build(:step)
    }
  end

  def step_factory do
    %Step{
      name: sequence(:name, &"my#{&1}step"),
      build: build(:build)
    }
  end

  def log_factory do
    %Log{
      order: sequence(:order, &(&1)),
      stdio: sequence(:stdio, &"log output line: #{&1}"),
      type: "stdout",
      job: build(:job)
    }
  end
end
