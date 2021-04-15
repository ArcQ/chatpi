defmodule Chatpi.ChatsTest do
  import Mock
  use Chatpi.DataCase
  alias Chatpi.Chats
  alias TestUtils

  setup_with_mocks([
    {Kaffe.Producer, [], [produce_sync: fn _key, _event -> "" end]}
  ]) do
    :ok
  end

  describe "chats" do
    use Chatpi.Fixtures, [:organization, :user, :chat, :message]
    import Chatpi.FixtureConstants

    alias Chatpi.Chats.{Chat, Member}
    alias Chatpi.Users

    test "list_chats_for_user/1 returns all chats for user" do
      {:ok, user, chat, _organization} = chat_fixture()

      expected_user = TestUtils.forget(user, :organization)
      result = auth_key_c() |> Chats.list_chats_for_user() |> List.first()
      assert result |> Map.get(:id) == chat.id
      assert result |> Map.get(:name) == chat.name
      assert result |> Map.get(:members) |> List.first() |> Map.get(:user) == expected_user
    end

    test "list_chats_for_user/1 returns all chats for user not for inactive" do
      {:ok, user, chat, _organization} = chat_fixture()

      chat
      |> Chats.update_chat(%{is_inactive: true})

      expected_user = TestUtils.forget(user, :organization)
      result = auth_key_c() |> Chats.list_chats_for_user() |> List.first()
      assert result == nil
    end

    test "get_chat/1 returns the chat with given id" do
      {:ok, user, chat, _organization} = chat_fixture()
      result = Chats.get_chat(chat.id)
      expected_user = TestUtils.forget(user, :organization)
      assert result |> Map.get(:id) == chat.id
      assert result |> Map.get(:name) == chat.name

      assert result |> Map.get(:members) |> List.first() |> Map.get(:user) == expected_user
    end

    test "get_chat/1 returns the chat with given id not for inactive" do
      {:ok, user, chat, _organization} = chat_fixture()

      chat
      |> Chats.update_chat(%{is_inactive: true})

      result = Chats.get_chat(chat.id)
      assert result == nil
    end

    test "create_chat/1 with valid data creates a chat" do
      {:ok, organization} = organization_fixture()

      assert {:ok, %Chat{} = chat} =
               Chats.create_chat(Map.merge(@valid_chat_attrs, %{organization: organization}))

      assert_called(
        Kaffe.Producer.produce_sync("chatpi_out", [{"key", "created-chat"}, {"chat", chat}])
      )

      assert chat.name == "fixture chat 1"
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      {:ok, _user, chat, _organization} = chat_fixture()

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, @update_chat_attrs)

      assert chat.name == "some updated name"
    end

    test "delete_chat/1 deletes the chat" do
      {:ok, _user, chat, _organization} = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert Enum.empty?(Chats.list_chats_for_user(chat.id))
    end

    test "change_chat/1 returns a chat changeset" do
      {:ok, _user, chat, _organization} = chat_fixture()
      chat = Map.delete(chat, :organization)
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end

    test "update_message/2 updates message_seen properly" do
      {:ok, user, chat, message, _organization} = message_fixture()

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
      {:ok, user, _chat, message, _organization} = message_fixture()

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

    test "add_chat_member adds chat member to chat" do
      {:ok, _user, chat, _message, organization} = message_fixture()

      {:ok, new_user} =
        Users.create_user(%{
          auth_key: "some auth key",
          username: "new_username_2",
          organization: organization
        })

      Chats.add_chat_member(organization.id, %{user_auth_key: new_user.auth_key, chat_id: chat.id})

      member = Chats.get_member(%{chat_id: chat.id, user_auth_key: new_user.auth_key})
      expected_user = TestUtils.forget(new_user, :organization)
      assert member.user == expected_user
    end

    test "add_chat_member returns error if not in same org" do
      {:ok, _user, chat, _message, organization} = message_fixture()

      {:ok, new_user} =
        Users.create_user(%{
          auth_key: "some auth key",
          username: "new_username_2",
          organization: organization
        })

      assert {:error, "User does not belong to this organization"} =
               Chats.add_chat_member(new_user.id, %{
                 user_auth_key: new_user.auth_key,
                 chat_id: chat.id
               })

      assert Chats.get_member(%{chat_id: chat.id, user_auth_key: new_user.auth_key}) == nil
    end

    test "remove_chat_members/1 removes chat member from chat" do
      {:ok, _user, chat, _message, organization} = message_fixture()

      {:ok, new_user} =
        Users.create_user(%{
          auth_key: "some auth key",
          username: "new_username_2",
          organization: organization
        })

      Chats.add_chat_member(organization.id, %{user_auth_key: new_user.auth_key, chat_id: chat.id})

      Chats.remove_chat_members(organization.id, chat.id, [new_user.auth_key])

      member = Chats.get_member(%{chat_id: chat.id, user_auth_key: new_user.auth_key})
      assert member == nil
    end

    test "remove_chat_members/1 does nothing organiaztion ids don't match" do
      {:ok, _user, chat, _message, organization} = message_fixture()

      {:ok, new_user} =
        Users.create_user(%{
          auth_key: "some auth key",
          username: "new_username_2",
          organization: organization
        })

      Chats.add_chat_member(organization.id, %{user_auth_key: new_user.auth_key, chat_id: chat.id})

      Chats.remove_chat_members(new_user.id, chat.id, [new_user.auth_key])

      member = Chats.get_member(%{chat_id: chat.id, user_auth_key: new_user.auth_key})
      expected_user = TestUtils.forget(new_user, :organization)
      assert member.user == expected_user
    end
  end
end
