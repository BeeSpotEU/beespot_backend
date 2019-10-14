defmodule BeespotBackend.BeespotBackendWeb.Location do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, except: [:__meta__]}
  schema "locations" do
    field :description, :string
    field :hives, :integer
    field :latitude, :string
    field :longitude, :string
    field :name, :string
    belongs_to :session, BeespotBackend.BeespotBackendWeb.Session

    timestamps()
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :description, :hives, :latitude, :longitude])
    |> validate_required([:latitude, :longitude])
  end
end
