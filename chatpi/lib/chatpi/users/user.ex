defmodule Chatpi.Users.User do
  @moduledoc false

  use Chatpi.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "chatpi_user" do
    field(:auth_key, :string)
    field(:username, :string)
    field(:is_inactive, :boolean)

    many_to_many(:chats, Chatpi.Chats.Chat, join_through: "chat_member")

    has_many(:messages, Chatpi.Messages.Message, foreign_key: :user_auth_key)

    embeds_many(:push_tokens, Chatpi.Users.PushToken, on_replace: :delete)

    timestamps()
  end

  @permitted_params ~w(
    username
    auth_key
    
    is_inactive
  )a

  @required_params ~w(
    auth_key
    username
  )a

  @make_inactive_params ~w(
    is_inactive
  )a

  @doc """
  Changeset definition for creating users
  """
  def insert_changeset(user, params \\ %{}) do
    user
    |> cast(params, @permitted_params)
    |> validate_required(@required_params)
  end

  @doc """
  Changeset definition for updating users
  """
  def update_changeset(user, params \\ %{}) do
    user
    |> cast(params, @permitted_params)
  end

  def update_push_tokens_changeset(user, params \\ %{}) do
    user
    |> cast(params, [])
    |> cast_embed(:push_tokens)
  end

  @doc """
  Changeset definition for updating users
  """
  def make_inactive_changset(user, params \\ %{}) do
    user
    |> cast(params, @make_inactive_params)
    |> validate_required([:id])
  end
end
