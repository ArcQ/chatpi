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
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:chat_id, :user_auth_key])
    |> validate_required([:chat_id, :user_auth_key])
    |> put_change(:id, Ecto.UUID.bingenerate())
  end
end
