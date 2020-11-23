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
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:user_id, :inserted_at, :classifier])
  end
end
