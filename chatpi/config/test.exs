use Mix.Config
# We don't run a server during test. If one is required,
# you can enable the server option below.
config :chatpi, ChatpiWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :chatpi, Chatpi.Repo,
  hostname: "localhost",
  database: "chatpi_test",
  username: System.get_env("TEST_DB_USER") || "postgres",
  password: System.get_env("TEST_DB_PASS") || "pw123",
  pool: Ecto.Adapters.SQL.Sandbox

config :arc,
  storage: Arc.Storage.Local
