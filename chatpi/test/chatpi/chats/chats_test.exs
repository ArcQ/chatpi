defmodule Unpreloader do
  def forget(struct, field, cardinality \\ :one) do
    %{struct |
      field => %Ecto.Association.NotLoaded{
        __field__: field,
        __owner__: struct.__struct__,
        __cardinality__: cardinality
      }
    }
  end
end

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
      assert Chats.list_chats_for_user(auth_key_c()) |> List.first |> Map.get(:id) == chat.id
    end

    test "get_chat/1 returns the chat with given id" do
      chat = chat_fixture()
      assert Chats.get_chat(chat.id) == chat
    end

    test "create_chat/1 with valid data creates a chat" do
      assert {:ok, %Chat{} = chat} = Chats.create_chat(@valid_attrs)

      assert chat.id == "some id"
    end

    test "create_chat/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chats.create_chat(@invalid_attrs)
    end

    test "update_chat/2 with valid data updates the chat" do
      chat = chat_fixture()

      assert {:ok, %Chat{} = chat} = Chats.update_chat(chat, @update_attrs)

      assert chat.id == "some updated id"
    end

    test "delete_chat/1 deletes the chat" do
      chat = chat_fixture()
      assert {:ok, %Chat{}} = Chats.delete_chat(chat)
      assert_raise Ecto.NoResultsError, fn -> Chats.get_chat!(chat.id) end
    end

    test "change_chat/1 returns a chat changeset" do
      chat = chat_fixture()
      assert %Ecto.Changeset{} = Chats.change_chat(chat)
    end
  end
end
