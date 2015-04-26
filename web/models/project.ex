defmodule Rabbitci.Project do
  use Rabbitci.Web, :model

  schema "projects" do
    field :name, :string
    field :repo, :string

    has_many :branches, Rabbitci.Branch

    timestamps
  end
end
