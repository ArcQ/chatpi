defmodule Chatpi.Chats.Chat do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "chat" do
    field(:name, :string)

    has_many(:members, Chatpi.Chats.Member)

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_assoc(:members, attrs[:members])
  end

  @doc false
  def update_changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name])
    |> put_assoc(:members, attrs[:members] || chat.members)
  end
end
