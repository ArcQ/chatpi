defmodule Chatpi.MessagesTest do
  use Chatpi.DataCase

  alias Chatpi.Users
  alias Chatpi.Chats
  alias Chatpi.Messages

  describe "messages" do
    alias Chatpi.Messages.Message

    use Chatpi.Fixtures, [:user, :chat, :message]

    test "list_messages_by_chat_id/0 returns all messages" do
      {:ok, user, chat, message} = message_fixture()

      message =
        message
        |> Map.put(:file, nil)

      assert Messages.list_messages_by_chat_id(chat.id) == [message]
    end

    test "list_messages_by_chat_id_query/0 returns all messages" do
      {:ok, user, chat, message} = message_fixture()

      message =
        message
        |> Map.put(:file, nil)

      assert Messages.list_messages_by_chat_id_query(chat.id, %Cursor{query_type: "after"}) == [
               message
             ]
    end

    test "create_message/1 with valid data creates a message" do
      {:ok, user, chat, message} = message_fixture()

      message =
        message
        |> Map.put(:file, nil)

      assert {:ok, %Message{} = message} =
               Messages.create_message(%{
                 text: "text",
                 user_auth_key: user.auth_key,
                 chat_id: chat.id
               })
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(@invalid_attrs)
    end

    test "delete_message/1 deletes the message" do
      {:ok, user, chat, message} = message_fixture()

      assert {:ok, %Message{}} = Messages.delete_message(%Message{id: message.id})
      assert Enum.empty?(Messages.list_messages_by_chat_id(chat.id))
    end

    test "change_message/1 returns a message changeset" do
      {:ok, user, chat, message} = message_fixture()

      assert %Ecto.Changeset{} = Messages.change_message(message)
    end
  end
end
