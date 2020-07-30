defmodule Chatpi.Users.User do
  @moduledoc false

  use Chatpi.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field(:auth_id, :string)
    field(:username, :string)
    field(:is_inactive, :boolean)

    many_to_many(:chats, Chatpi.Chats.Chat, join_through: "chats_members")

    has_many(:messages, Chatpi.Messages.Message)

    timestamps()
  end

  @permitted_params ~w(
    username
    auth_id
    is_inactive
  )

  @required_params ~w(
    auth_id
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

  @doc """
  Changeset definition for updating users
  """
  def make_inactive_changset(user, params \\ %{}) do
    user
    |> cast(params, @make_inactive_params)
  end
end
