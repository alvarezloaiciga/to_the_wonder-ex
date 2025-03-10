defmodule ToTheWonder.Trips.Trip do
  use Ecto.Schema
  import Ecto.Changeset

  schema "trips" do
    field :name, :string
    field :logo, :string
    field :description, :string
    field :from_date, :date
    field :to_date, :date
    field :header_background_image, :string
    field :route_image, :string
    field :route_background_image, :string
    field :itinerary, :map
    field :hotels_gallery, {:array, :map}
    field :includes, {:array, :string}
    field :excludes, {:array, :string}
    field :trip_gallery, {:array, :map}
    field :physical_effort, :integer
    field :trip_reviews_background_image, :string
    field :experience_gallery, {:array, :map}
    field :capacity, :integer
    field :launch_discount, :decimal
    field :reservation_price, :decimal
    field :launch_price, :decimal
    field :regular_price, :decimal

    has_many :trip_reviews, ToTheWonder.Trips.TripReview
    many_to_many :instructors, ToTheWonder.Accounts.User, join_through: "trips_instructors"

    timestamps()
  end

  def changeset(trip, attrs) do
    trip
    |> cast(attrs, [
      :name,
      :logo,
      :description,
      :from_date,
      :to_date,
      :header_background_image,
      :route_image,
      :route_background_image,
      :itinerary,
      :hotels_gallery,
      :includes,
      :excludes,
      :trip_gallery,
      :physical_effort,
      :trip_reviews_background_image,
      :experience_gallery,
      :capacity,
      :launch_discount,
      :reservation_price,
      :launch_price,
      :regular_price
    ])
    |> validate_required([
      :name,
      :from_date,
      :to_date
    ])
    |> validate_number(:physical_effort, greater_than_or_equal_to: 1, less_than_or_equal_to: 5)
    |> validate_number(:capacity, greater_than: 0)
    |> validate_dates()
  end

  defp validate_dates(changeset) do
    case {get_field(changeset, :from_date), get_field(changeset, :to_date)} do
      {from_date, to_date} when not is_nil(from_date) and not is_nil(to_date) ->
        if Date.compare(from_date, to_date) == :gt do
          add_error(changeset, :to_date, "must be after from_date")
        else
          changeset
        end

      _ ->
        changeset
    end
  end
end
