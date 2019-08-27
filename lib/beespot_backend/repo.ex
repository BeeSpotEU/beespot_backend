defmodule BeespotBackend.Repo do
  use Ecto.Repo,
    otp_app: :beespot_backend,
    adapter: Ecto.Adapters.Postgres
end
