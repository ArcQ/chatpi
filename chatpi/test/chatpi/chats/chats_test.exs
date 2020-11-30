defmodule Chatpi.ChatsTest do
  import Mock
  use Chatpi.DataCase
  alias Chatpi.Chats

  setup_with_mocks([
    {Kaffe.Producer, [], [produce_sync: fn _key, _event -> "" end]}
  ]) do
    :ok
  end

  describe "chats" do
    use Chatpi.Fixtures, [:user, :chat, :message]
    import Chatpi.FixtureConstants

    alias Chatpi.Chats.Chat
    alias Chatpi.Chats.Member

    test "list_chats_for_user/1 returns all chats for user" do
      {:ok, user, chat} = chat_fixture()
      result = auth_key_c() |> Chats.list_chats_for_user() |> List.first()
      assert result |> Map.get(:id) == chat.id
      assert result |> Map.get(:name) == chat.name
      assert result |> Map.get(:members) |> List.first() |> Map.get(:user) == user
    end

    test "get_chat/1 returns the chat with given id" do
      {:ok, user, chat} = chat_fixture()
      result = Chats.get_chat(chat.id)
      assert result |> Map.get(:id) == chat.id
      assert result |> Map.get(:name) == chat.name

      assert result |> Map.get(:members) |> List.first() |> Map.get(:user) == user
    end

    test "create_chat/1 with valid data creates a chat" do
      assert {:ok, %Chat{} = chat} = Chats.create_chat(@valid_chat_attrs)

      assert_called(
        Kaffe.Producer.produce_sync("chatpi_out", [{"key", "created-chat"}, {"chat", chat}])
      )

      assert chat.name == "fixture chat 1"
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      {:ok, _user, chat} = chat_fixture()

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, @update_chat_attrs)

      assert chat.name == "some updated name"
    end

    test "delete_chat/1 deletes the chat" do
      {:ok, _user, chat} = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert Enum.empty?(Chats.list_chats_for_user(chat.id))
    end

    test "change_chat/1 returns a chat changeset" do
      {:ok, _user, chat} = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end

    test "update_message/2 updates message_seen properly" do
      {:ok, user, chat, message} = message_fixture()

      assert {:ok, %Member{} = member} =
               Chats.find_and_update_member(
                 %{
                   message_id: message.id,
                   user_auth_key: user.auth_key
                 },
                 %{
                   message_seen_id: message.id,
                   unread_messages: 0
                 }
               )

      result = Chats.get_member_by_id(member.id)

      assert result.chat_id == chat.id
      assert result.user_auth_key == user.auth_key
      assert result.message_seen_id == message.id
    end

    test "update_chat_members/1 mute notifications works" do
      {:ok, user, chat, message} = message_fixture()

      assert {:ok, %Member{is_muted: false} = member} =
               Chats.find_and_update_member(
                 %{
                   message_id: message.id,
                   user_auth_key: user.auth_key
                 },
                 %{
                   is_muted: false
                 }
               )
    end

    test "get_member/1 gets member by query" do
      {:ok, user, _chat, message} = message_fixture()
      message_id = message.id

      assert member = Chats.get_member(%{message_id: message_id, user_auth_key: user.auth_key})
      assert member.chat_id == message.chat_id
      assert member.user_auth_key == user.auth_key
    end
  end
end
