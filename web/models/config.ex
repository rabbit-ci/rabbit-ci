defmodule Rabbitci.Config do
  use Rabbitci.Web, :model

  schema "configs" do
    field :body
    belongs_to :build, Rabbitci.Build
    timestamps
  end

  # Need to setup changeset for this
end
