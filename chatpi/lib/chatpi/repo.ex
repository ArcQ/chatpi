defmodule Chatpi.Repo do
  use Ecto.Repo,
    otp_app: :chatpi,
    adapter: Ecto.Adapters.Postgres
end
