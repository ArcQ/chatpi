defmodule Chatpi.ChatsTest do
  import Mock
  use Chatpi.DataCase

  alias Ecto.Changeset
  alias Chatpi.Chats

  setup_with_mocks([
    {Kaffe.Producer, [], [produce_sync: fn key, event -> "" end]}
  ]) do
    :ok
  end

  describe "chats" do
    use Chatpi.Fixtures, [:user, :chat]
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
      {:ok, user, chat} = chat_fixture()

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, @update_chat_attrs)

      assert chat.name == "some updated name"
    end

    test "delete_chat/1 deletes the chat" do
      {:ok, user, chat} = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert Enum.empty?(Chats.list_chats_for_user(chat.id))
    end

    test "change_chat/1 returns a chat changeset" do
      {:ok, user, chat} = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end
end
