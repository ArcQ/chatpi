defmodule Chatpi.Messages.Message do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "message" do
    field(:text, :string)
    embeds_many(:reactions, Chatpi.Messages.Reaction, on_replace: :delete)

    # in case consumer of chatpi needs to keep track of some custom object that needs to
    # belong inside of the messages list view in a particular place
    field(:custom_details, :map)

    field(:is_system, :boolean)

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
    |> cast(attrs, [
      :text,
      :user_auth_key,
      :chat_id,
      :reply_target_id,
      :custom_details,
      :is_system
    ])
    |> validate_required([:user_auth_key, :chat_id])
    |> cast_assoc(:user)
    |> cast_assoc(:chat)
    |> cast_assoc(:reply_target, required: false)

    # |> cast_assoc(:files, required: false)
  end

  @doc false
  def update_changeset(message, attrs) do
    message
    |> cast(attrs, [])
    |> put_assoc(:files, attrs[:files] || nil, required: false)
  end

  @doc false
  def update_reactions_changeset(message, attrs) do
    message
    |> cast(attrs, [])
    |> cast_embed(:reactions)
  end
end
