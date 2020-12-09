defmodule Chatpi.Chats do
  @moduledoc """
  The Chats context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.Repo

  alias Chatpi.{Messages.Message, Chats.Chat, Users, Users.User, Chats.Member, MessagePublisher}

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

  def get_member_by_id(id) do
    Member
    |> where([member], member.id == ^id)
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

  def list_user_expo_tokens_for_chat(chat_id) do
    Repo.all(
      from(user in User,
        select: user.push_token,
        distinct: true,
        inner_join: member in assoc(user, :members),
        on: member.user_auth_key == user.auth_key and member.chat_id == ^chat_id
      )
    )
  end

  def create_chat_with_members(%{name: name, members: user_auth_keys, organization: organization}) do
    users =
      user_auth_keys
      |> Users.list_users_by_ids()

    if length(users) == length(users) do
      {:ok, chat} = create_chat(%{name: name, members: [], organization: organization})

      members =
        users
        |> Enum.map(&%Member{user: &1, chat: chat})

      chat
      |> update_chat(%{members: Enum.concat(chat.members, members)})
    end
  end

  def create_chat(attrs) do
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

  # def refresh_messages_read(%{chat_id: chat_id} = query) do
  #   subset_members =
  #     Member
  #     |> where([member], member.chat_id == ^chat_id)

  #   Message
  #   |> where([message], message.chat_id == ^chat_id)
  #   |> query_messages_paged(50).()

  #   Member
  #   |> distinct(true)
  #   |> join(:inner, [chat], member in Member, on: member.user_auth_key == ^auth_key)
  #   |> where([chat, member], chat.id == member.chat_id)
  #   |> preload(members: :user)
  #   |> get_member
  #   |> Member.update_message_seen_changeset(%{message_seen_id: message_seen_id})
  #   |> Repo.update()
  # end

  def find_and_update_member(
        query,
        attrs
      ) do
    query
    |> get_member
    |> update_chat_members(attrs)
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

  def update_chat_members(%Member{} = member, attrs) do
    member
    |> Member.update_changeset(attrs)
    |> Repo.update()
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

  def get_member(%{chat_id: chat_id, user_auth_key: user_auth_key} = _query) do
    Member
    |> where([member], member.user_auth_key == ^user_auth_key and member.chat_id == ^chat_id)
    |> Repo.all()
    |> List.first()
  end

  def get_member(%{message_id: message_id, user_auth_key: user_auth_key} = _query) do
    Member
    |> join(:inner, [member], chat in Chat, on: chat.id == member.chat_id)
    |> join(:inner, [member, chat], message in Message,
      on: message.chat_id == chat.id and message.id == ^message_id
    )
    |> where([member], member.user_auth_key == ^user_auth_key)
    |> Repo.all()
    |> List.first()
  end
end
