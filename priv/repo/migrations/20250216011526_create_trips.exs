defmodule ToTheWonder.Repo.Migrations.CreateTrips do
  use Ecto.Migration

  def change do
    create table(:trips) do
      add :name, :string, null: false
      add :logo, :string
      add :description, :text
      add :from_date, :date, null: false
      add :to_date, :date, null: false
      add :header_background_image, :string
      add :route_image, :string
      add :route_background_image, :string
      add :itinerary, :map
      add :hotels_gallery, {:array, :map}
      add :includes, {:array, :string}
      add :excludes, {:array, :string}
      add :trip_gallery, {:array, :map}
      add :physical_effort, :integer
      add :trip_reviews_background_image, :string
      add :experience_gallery, {:array, :map}
      add :capacity, :integer
      add :launch_discount, :decimal, precision: 10, scale: 2
      add :reservation_price, :decimal, precision: 10, scale: 2
      add :launch_price, :decimal, precision: 10, scale: 2
      add :regular_price, :decimal, precision: 10, scale: 2

      timestamps()
    end

    create table(:trip_reviews) do
      add :trip_id, references(:trips, on_delete: :delete_all)
      add :name, :string
      add :description, :text
      add :image, :string

      timestamps()
    end

    create table(:trips_instructors) do
      add :trip_id, references(:trips, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:trip_reviews, [:trip_id])
    create index(:trips_instructors, [:trip_id])
    create index(:trips_instructors, [:user_id])
    create unique_index(:trips_instructors, [:trip_id, :user_id])
  end
end
