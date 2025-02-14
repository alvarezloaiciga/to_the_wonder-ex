defmodule ToTheWonder.Repo.Migrations.AddProfileFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :name, :string, null: false
      add :picture, :map
      add :bio, :text
      add :instagram_handle, :string
    end
  end
end
