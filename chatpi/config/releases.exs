import Config

config :chatpi, ChatpiWeb.Endpoint,
  http: [:inet6, port: System.get_env("PORT") || 4000],
  secret_key_base: System.get_env("SECRET_KEY_BASE")

config :chatpi, Chatpi.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: System.get_env("DB_USER"),
  password: System.get_env("DB_PASS"),
  database: System.get_env("CHATPI_DB_NAME") || "chatpi_dev",
  hostname: System.get_env("DB_HOST"),
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
  # ssl: true

config :arc,
  storage: Arc.Storage.S3,
  bucket: {:system, "AWS_S3_BUCKET"}

config :ex_aws,
  access_key_id: [{:system, "AWS_ACCESS_KEY_ID"}, :instance_role],
  secret_access_key: [{:system, "AWS_SECRET_ACCESS_KEY"}, :instance_role],
  region: System.get_env("AWS_REGION"),
  s3: [
    scheme: "https://",
    host: "s3-" <> System.get_env("AWS_REGION") <> ".amazonaws.com",
    region: System.get_env("AWS_REGION")
  ]
