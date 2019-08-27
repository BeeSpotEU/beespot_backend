# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :beespot_backend,
  ecto_repos: [BeespotBackend.Repo]

# Configures the endpoint
config :beespot_backend, BeespotBackendWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7wBOesxPfFW+Ps5aF32KycOWSzCQqBDxDmA7Uix3coH9XhIaS6cemUTcOE8/6kAB",
  render_errors: [view: BeespotBackendWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: BeespotBackend.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
