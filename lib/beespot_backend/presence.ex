defmodule BeespotBackend.Presence do
  use Phoenix.Presence,
    otp_app: :beespot_backend,
    pubsub_server: BeespotBackend.PubSub
end
