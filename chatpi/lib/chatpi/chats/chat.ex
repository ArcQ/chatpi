defmodule Chatpi.Chats.Chat do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "chats" do
    field(:name, :string)

    many_to_many(:users, Chatpi.Users.User,
      join_through: "chats_members",
      join_keys: [chat_id: :id, user_id: :auth_id])
    has_many(:messages, Chatpi.Messages.Message)
    has_many(:members, Chatpi.Chats.Member)

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_assoc(:users, attrs.users)
  end
end
