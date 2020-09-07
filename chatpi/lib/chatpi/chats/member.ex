defmodule Chatpi.Chats.Member do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "chats_members" do
    belongs_to(:chat, Chatpi.Chats.Chat, type: Ecto.UUID)
    belongs_to(:user, Chatpi.Users.User, type: :string, references: :auth_key)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:chat_id, :user_id])
    |> validate_required([:chat_id, :user_id])
    # |> put_change(:id, Ecto.UUID.bingenerate())
  end
end
