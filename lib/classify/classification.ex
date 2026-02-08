defmodule Classify.Classifier.Classification do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  schema "classify" do
    field :brick, :string
    field :description, :string
    field :active, :string

    timestamps(inserted_at: :inserted_at, updated_at: :updated_at)
  end

  @doc false
  def changeset(classification, attrs) do
    classification
    |> cast(attrs, [:brick, :description, :active])
    |> validate_required([:brick, :description])
  end
end
