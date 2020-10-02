defmodule Chatpi.ChatsTest do
  use Chatpi.DataCase

  alias Ecto.Changeset
  alias Chatpi.Chats

  describe "chats" do
    use Chatpi.Fixtures, [:user, :chat]
    import Chatpi.FixtureConstants

    alias Chatpi.Chats.Chat
    alias Chatpi.Chats.Member

    test "list_chats_for_user/1 returns all chats for user" do
      chat = chat_fixture()
      result = Chats.list_chats_for_user(auth_key_c()) |> List.first
      assert result |> Map.get(:id) == chat.id
      assert result |> Map.get(:name) == chat.name
      assert result |> Map.get(:members) |> List.first |> Map.get(:id) ==
        chat |> Map.get(:members) |> List.first |> Map.get(:id)
    end

    test "get_chat/1 returns the chat with given id" do
      chat = chat_fixture()
      result = Chats.get_chat(chat.id)
      assert result |> Map.get(:id) == chat.id
      assert result |> Map.get(:name) == chat.name
      assert result |> Map.get(:members) |> List.first |> Map.get(:id) ==
        chat |> Map.get(:members) |> List.first |> Map.get(:id)
    end

    test "create_chat/1 with valid data creates a chat" do
      assert {:ok, %Chat{} = chat} = Chats.create_chat(@valid_attrs)

      assert chat.name == "fixture chat 1"
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, @update_attrs)

      assert chat.name == "some updated name"
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert Enum.empty?(Chats.list_chats_for_user(chat.id))
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end
end
