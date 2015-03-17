defmodule Rabbitci.Project do
  use Ecto.Model

  schema "projects" do
    field :name, :string
    field :repo, :string

    has_many :branches, Rabbitci.Branch
  end
end
