defmodule Chatpi.Messages.Message do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "message" do
    field(:text, :string)
    field(:seen_by_id, :integer)
    field(:seen_at, :naive_datetime)
    has_many(:files, Chatpi.Messages.File)

    belongs_to(:chat, Chatpi.Chats.Chat, type: Ecto.UUID)

    belongs_to(:user, Chatpi.Users.User,
      type: :string,
      references: :auth_key,
      foreign_key: :user_auth_key
    )

    belongs_to(:reply_target, Chatpi.Messages.Message)

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :user_auth_key, :chat_id, :seen_by_id, :seen_at])
    |> validate_required([:text, :user_auth_key, :chat_id])
    |> cast_assoc(:user)
    |> cast_assoc(:chat)
    |> cast_assoc(:reply_target, required: false)

    # |> cast_assoc(:files, required: false)
  end

  @doc false
  def update_changeset(message, attrs) do
    message
    |> cast(attrs, [])
    |> put_assoc(:files, attrs[:files], required: false)
  end
end
