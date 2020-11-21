defmodule Chatpi.Messages.Reaction do
  @moduledoc false

  use Chatpi.Schema

  import Ecto.Changeset

  embedded_schema do
    field(:user_id)
    field(:classifier)

    timestamps()
  end

  @doc false
  def changeset(reaction, attrs) do
    reaction
    |> cast(attrs, [:user_id, :inserted_at, :classifier])
  end
end
