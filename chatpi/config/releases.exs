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

# config :arc,
#   storage: Arc.Storage.S3,
#   bucket: {:system, "AWS_S3_BUCKET"}

# config :ex_aws,
#   access_key_id: [{:system, "AWS_SERVICE_ACCESS_KEY_ID"}, :instance_role],
#   secret_access_key: [{:system, "AWS_SERVICE_SECRET_ACCESS_KEY"}, :instance_role],
#   region: System.get_env("AWS_REGION"),
#   s3: [
#     scheme: "https://",
#     host: "s3-" <> System.get_env("AWS_REGION") <> ".amazonaws.com",
#     region: System.get_env("AWS_REGION")
#   ]

config :kaffe,
  producer: [
    endpoints: [{System.get_env("KAFKA_HOST"), 9092}],
    topics: ["chatpi-out"],
    ssl: true,
    partition_strategy: :md5,
    sasl: %{
      mechanism: :plain,
      login: System.get_env("KAFKA_USER"),
      password: System.get_env("KAFKA_PASSWORD")
    }
  ],
  consumer: [
    endpoints: [{System.get_env("KAFKA_HOST"), 9092}],
    topics: ["chatpi"],
    consumer_group: "chatpi-consumer",
    message_handler: Chatpi.MessageProcessor,
    offset_reset_policy: :reset_to_latest,
    max_bytes: 500_000,
    worker_allocation_strategy: :worker_per_topic_partition,
    ssl: true,
    sasl: %{
      mechanism: :plain,
      login: System.get_env("KAFKA_USER"),
      password: System.get_env("KAFKA_PASSWORD")
    }
  ]

config :chatpi, :env, :prod
