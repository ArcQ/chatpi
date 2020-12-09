defmodule Chatpi.Users.User do
  @moduledoc false

  use Chatpi.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "chatpi_user" do
    field(:auth_key, :string)
    field(:username, :string)
    field(:is_inactive, :boolean)
    field(:is_admin, :boolean)

    many_to_many(:chats, Chatpi.Chats.Chat, join_through: "chat_member")

    has_many(:messages, Chatpi.Messages.Message, foreign_key: :user_auth_key)

    embeds_many(:push_tokens, Chatpi.Users.PushToken, on_replace: :delete)

    belongs_to(:organization, Chatpi.Organizations.Organization, type: Ecto.UUID)

    timestamps()
  end

  @permitted_attrs ~w(
    username
    auth_key
    
    is_inactive
  )a

  @required_attrs ~w(
    auth_key
    username
  )a

  @make_inactive_attrs ~w(
    is_inactive
  )a

  @doc """
  Changeset definition for creating users
  """
  def insert_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_attrs)
    |> validate_required(@required_attrs)
    |> put_assoc(:organization, attrs[:organization])
  end

  @doc """
  Changeset definition for updating users
  """
  def update_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @permitted_attrs)
  end

  def update_push_tokens_changeset(user, attrs \\ %{}) do
    user
    |> cast(attrs, [])
    |> cast_embed(:push_tokens)
  end

  @doc """
  Changeset definition for updating users
  """
  def make_inactive_changset(user, attrs \\ %{}) do
    user
    |> cast(attrs, @make_inactive_attrs)
    |> validate_required([:id])
  end
end
