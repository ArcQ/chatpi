defmodule Chatpi.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.Repo

  alias Chatpi.{Chats.Chat, Users.User}

  @doc """
  Returns the list of chats by auth_key

  ## Examples

  iex> list_chats_by_auth_key(auth_key)
  [%Chat{}, ...]

  """
  def list_chats_for_user(auth_key) do
    Repo.all(
      from(c in Chat,
        distinct: true,
        inner_join: u1 in assoc(c, :users),
        where: u1.auth_key == ^auth_key
      )
    )
  end

  @doc """
  Gets a single chat.

  Raises `Ecto.NoResultsError` if the Chat does not exist.

  ## Examples

  iex> get_chat(123)
  %Chat{}

  iex> get_chat(456)
  ** (Ecto.NoResultsError)

  """
  def get_chat(id) do
    Chat
    |> where([chat], chat.id == ^id)
    |> preload([members: :user])
    |> Repo.all
    |> List.first
  end

  @doc """
  Gets a chat between 2 users
  """
  def get_chats_between_users(cauth_key, auth_key) do
    Repo.all(
      from(c in Chat,
        distinct: true,
        left_join: u1 in assoc(c, :users),
        inner_join: u2 in assoc(c, :users),
        on: u2.auth_key == ^cauth_key,
        where: u1.auth_key == ^auth_key
      )
    )
  end

  @doc """
  Creates a chat.

  ## Examples

  iex> create_chat(%{field: value})
  {:ok, %Chat{}}

  iex> create_chat(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_chat(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat.

  ## Examples

  iex> update_chat(chat, %{field: new_value})
  {:ok, %Chat{}}

  iex> update_chat(chat, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Chat.

  ## Examples

  iex> delete_chat(chat)
  {:ok, %Chat{}}

  iex> delete_chat(chat)
  {:error, %Ecto.Changeset{}}

  """
  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat changes.

  ## Examples

  iex> change_chat(chat)
  %Ecto.Changeset{source: %Chat{}}

  """
  def change_chat(%Chat{} = chat) do
    Chat.changeset(chat, %{})
  end

  @doc """
  Checks if auth_key is a member of chat_id

  ## Examples

  iex> list_chats()
  [%Chat{}, ...]

  """
  def is_member(auth_key, chat_id) do
    Chat
    |> where([chat], chat.id == ^chat_id)
    |> join(:inner, [chat], user in User, on: user.auth_key == ^auth_key)
    |> Repo.exists?
  end
end
