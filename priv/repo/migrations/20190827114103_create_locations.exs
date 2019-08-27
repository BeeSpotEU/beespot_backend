defmodule BeespotBackend.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :description, :string
      add :hives, :integer
      add :latitude, :string
      add :longitude, :string

      timestamps()
    end

  end
end
