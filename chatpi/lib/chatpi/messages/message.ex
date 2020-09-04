defmodule Chatpi.Messages.Message do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "messages" do
    field(:text, :string)
    field(:seen_by_id, :integer)
    field(:seen_at, :naive_datetime)

    belongs_to(:user, Chatpi.Users.User, references: :uuid, type: :string)
    belongs_to(:chat, Chatpi.Chats.Chat, references: :uuid, type: :string)
    has_one(:file, Chatpi.Uploads.File)

    timestamps()
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:text, :user_id, :chat_id, :seen_by_id, :seen_at])
    |> validate_required([:text, :user_id, :chat_id])
    |> cast_assoc(:user)
    |> cast_assoc(:chat)
    |> cast_assoc(:file)
  end
end
