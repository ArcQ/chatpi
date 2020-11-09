defmodule Chatpi.MessagesTest do
  use Chatpi.DataCase

  alias Chatpi.Messages

  describe "messages" do
    alias Chatpi.Messages.Message

    use Chatpi.Fixtures, [:user, :chat, :message]

    test "list_messages_by_chat_id/1 returns all messages" do
      {:ok, _user, chat, message} = message_fixture()

      expected_result =
        message
        |> Map.put(:files, [])
        |> Map.put(:reply_target, nil)

      assert Messages.list_messages_by_chat_id(chat.id) == [expected_result]
    end

    test "find_by_id/1 returns all correct message" do
      {:ok, _user, _chat, message} = message_fixture()

      expected_result =
        message
        |> Map.put(:files, [])
        |> Map.put(:reply_target, nil)

      assert Messages.find_by_id(message.id) == expected_result
    end

    test "list_messages_by_chat_id_query/2 default returns all messages" do
      {:ok, _user, chat, message} = message_fixture()

      expected_result =
        message
        |> Map.put(:files, [])
        |> Map.put(:reply_target, nil)

      assert Messages.list_messages_by_chat_id_query(chat.id, %Messages.Cursor{}) == [
               expected_result
             ]
    end

    test "list_messages_by_chat_id_query/2 query between" do
      {:ok, user, chat, _message} = message_fixture()

      {:ok, second_message} =
        Messages.create_message(%{
          text: "text1",
          user_auth_key: user.auth_key,
          chat_id: chat.id
        })

      Process.sleep(1000)

      Messages.create_message(%{
        text: "text2",
        user_auth_key: user.auth_key,
        chat_id: chat.id
      })

      Messages.create_message(%{
        text: "text3",
        user_auth_key: user.auth_key,
        chat_id: chat.id
      })

      assert chat.id
             |> Messages.list_messages_by_chat_id_query(%Messages.Cursor{
               after_timestamp: NaiveDateTime.to_iso8601(second_message.inserted_at)
             })
             |> length() == 2
    end

    test "create_message/1 with valid data creates a message" do
      {:ok, user, chat, _message} = message_fixture()

      assert {:ok, %Message{} = message} =
               Messages.create_message(%{
                 text: "text",
                 user_auth_key: user.auth_key,
                 chat_id: chat.id
               })
    end

    test "create_message/1 with file works" do
      assert {:ok, _user, _chat, message} = message_fixture_reply_with_file()
    end

    test "create_message/1 with reply works" do
      {:ok, user, chat, message} = message_fixture()

      assert {:ok, %Message{} = message} =
               Messages.create_message(%{
                 reply_target_id: message.id,
                 text: "text",
                 user_auth_key: user.auth_key,
                 chat_id: chat.id
               })
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messages.create_message(@invalid_attrs)
    end

    test "delete_message/1 deletes the message" do
      {:ok, _user, chat, message} = message_fixture()

      assert {:ok, %Message{}} = Messages.delete_message(%Message{id: message.id})
      assert Enum.empty?(Messages.list_messages_by_chat_id(chat.id))
    end

    test "change_message/1 returns a message changeset" do
      {:ok, _user, _chat, message} = message_fixture()

      assert %Ecto.Changeset{} = Messages.change_message(message)
    end

    test "upsert_reaction/2 inserts reaction when it doesn't exist" do
      {:ok, user, _chat, message} = message_fixture()

      reaction = %{
        user_id: user.id,
        classifier: "cry"
      }

      {:ok, message} = Messages.upsert_reaction(message.id, reaction)

      assert message.reactions |> length == 1

      user_id = user.id

      assert %{
               user_id: ^user_id,
               classifier: "cry"
             } = message.reactions |> List.first()
    end

    test "upsert_reaction/2 replaces reaction when it does exist" do
      {:ok, user, _chat, message} = message_fixture()

      reaction = %{
        user_id: user.id,
        classifier: "cry"
      }

      {:ok, message} = Messages.upsert_reaction(message.id, reaction)

      reaction2 = %{
        user_id: user.id,
        classifier: "laugh"
      }

      {:ok, message} = Messages.upsert_reaction(message.id, reaction2)

      assert message.reactions |> length == 1

      user_id = user.id

      assert %{
               user_id: ^user_id,
               classifier: "laugh"
             } = message.reactions |> List.first()
    end
  end
end
