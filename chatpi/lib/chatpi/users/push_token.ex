defmodule Chatpi.Users.PushToken do
  @moduledoc false

  use Chatpi.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:type, :string, size: 10)
    field(:device_id, :string, size: 50)
    field(:token, :string, size: 50)

    timestamps()
  end

  @doc false
  def changeset(push_token, attrs) do
    push_token
    |> cast(attrs, [:type, :device_id, :token])
  end
end
