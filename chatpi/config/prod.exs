use Mix.Config

# Finally import the config/prod.secret.exs which should be versioned
# separately.
# import_config "prod.secret.exs"
config :chatpi, ChatpiWeb.Endpoint,

config :logger, level: :info
