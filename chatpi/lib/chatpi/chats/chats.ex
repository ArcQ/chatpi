defmodule Chatpi.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.Repo

  alias Chatpi.{Chats.Chat, Users.User, Chats.Member, MessagePublisher}

  def list_chats_for_user(auth_key) do
    Chat
    |> distinct(true)
    |> join(:inner, [chat], member in Member, on: member.user_auth_key == ^auth_key)
    |> where([chat, member], chat.id == member.chat_id)
    |> preload(members: :user)
    |> Repo.all()
  end

  def get_chat(id) do
    Chat
    |> where([chat], chat.id == ^id)
    |> preload(members: :user)
    |> Repo.all()
    |> List.first()
  end

  def get_chats_between_users(cauth_key, auth_key) do
    Repo.all(
      from(c in Chat,
        distinct: true,
        inner_join: m1 in assoc(c, :members),
        inner_join: m2 in assoc(c, :members),
        on: m2.user_auth_key == ^cauth_key,
        where: m1.user_auth_key == ^auth_key
      )
    )
  end

  def create_chat(attrs \\ %{}) do
    case %Chat{}
         |> Chat.changeset(attrs)
         |> Repo.insert() do
      {:ok, chat} ->
        MessagePublisher.publish("created-chat", chat)
        {:ok, chat}

      {:error, %Ecto.Changeset{}} ->
        {:error, %Ecto.Changeset{}}
    end
  end

  def update_chat(%Chat{} = chat, attrs) do
    chat
    |> Chat.update_changeset(attrs)
    |> Repo.update()
  end

  def add_chat_members(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  def remove_chat_members(attrs \\ %{}) do
    %Chat{}
    |> Chat.changeset(attrs)
    |> Repo.insert()
  end

  def delete_chat(%Chat{} = chat) do
    Repo.delete(chat)
  end

  def change_chat(%Chat{} = chat) do
    Chat.changeset(chat, %{})
  end

  def is_member(auth_key, chat_id) do
    Chat
    |> where([chat], chat.id == ^chat_id)
    |> join(:inner, [chat], user in User, on: user.auth_key == ^auth_key)
    |> Repo.exists?()
  end
end
