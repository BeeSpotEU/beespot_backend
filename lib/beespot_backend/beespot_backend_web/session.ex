defmodule BeespotBackend.BeespotBackendWeb.Session do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sessions" do
    field :session_id, :string
    has_many :locations, BeespotBackend.BeespotBackendWeb.Location

    timestamps()
  end

  @doc false
  def changeset(session, attrs) do
    session
    |> cast(attrs, [:session_id])
    |> validate_required([:session_id])
    |> unique_constraint(:session_id)
  end
end
