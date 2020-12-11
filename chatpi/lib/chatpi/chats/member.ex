defmodule Chatpi.Chats.Member do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "chat_member" do
    belongs_to(:chat, Chatpi.Chats.Chat, type: Ecto.UUID)

    belongs_to(:user, Chatpi.Users.User,
      type: :string,
      references: :auth_key,
      foreign_key: :user_auth_key
    )

    belongs_to(:message_seen, Chatpi.Messages.Message, type: Ecto.UUID)

    field(:is_muted, :boolean, default: false)

    # negative one will stand for just added user, maybe show a notification without a number?
    field(:unread_messages, :integer, default: -1)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:chat_id, :user_auth_key])
    |> validate_required([:chat_id, :user_auth_key])

    # |> put_change(:id, Ecto.UUID.bingenerate())
  end

  @doc false
  def update_changeset(member, attrs) do
    member
    |> cast(attrs, [:is_muted, :message_seen_id])
    |> cast_assoc(:message_seen, required: false)
  end
end
