# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :mt_bitcoin_phoenix,
  ecto_repos: [MtBitcoinPhoenix.Repo]

# Configures the endpoint
config :mt_bitcoin_phoenix, MtBitcoinPhoenixWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "NHPP8SdWz00WAAen1RZgue0ENe/thAR/TfGhn9jtaBG6H6Ha03xIUdsna+IHoZou",
  render_errors: [view: MtBitcoinPhoenixWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: MtBitcoinPhoenix.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
