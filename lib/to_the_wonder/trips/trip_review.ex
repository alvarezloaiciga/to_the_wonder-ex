defmodule ToTheWonder.Trips.TripReview do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trip_reviews" do
    field :name, :string
    field :description, :string
    field :image, :string

    belongs_to :trip, ToTheWonder.Trips.Trip

    timestamps()
  end

  def changeset(trip_review, attrs) do
    trip_review
    |> cast(attrs, [:name, :description, :image, :trip_id])
    |> validate_required([:name, :description, :trip_id])
  end
end
