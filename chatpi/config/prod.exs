use Mix.Config

# Finally import the config/prod.secret.exs which should be versioned
# separately.
# import_config "prod.secret.exs"
config :logger, level: :info
config :chatpi, :env, :prod
