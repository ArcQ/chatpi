defmodule ChatpiWeb.MessageProcessorTest do
  @moduledoc false

  import Mock
  use Chatpi.DataCase
  use Chatpi.Fixtures, [:organization, :user, :chat, :message]
  alias Chatpi.MessageProcessor
  alias Chatpi.{Users, Chats, Chats.Chat}

  setup_with_mocks([
    {Kaffe.Producer, [], [produce_sync: fn _key, _event -> "" end]}
  ]) do
    :ok
  end

  describe "handle_message" do
    test "upsert-user", %{} do
      {:ok, _organization} = organization_fixture()

      MessageProcessor.handle_messages([
        %{
          headers: [],
          key: "upsert-user",
          offset: 27,
          partition: 4,
          topic: "chatpi",
          ts: 1_603_425_015_521,
          ts_type: :create,
          value: get_json("test/support/messages/upsert-user.json")
        }
      ])

      assert Users.list_users() |> length == 4
    end

    test "upsert-chat-entity", %{} do
      {:ok, user, _organization} = user_fixture()

      MessageProcessor.handle_messages([
        %{
          key: "upsert-chat-entity",
          value: get_json("test/support/messages/upsert-chat-entity.json")
        }
      ])

      assert user.auth_key |> Chats.list_chats_for_user() |> length == 1
    end

    test "add-member-to-chat-entity", %{} do
      {:ok, user, organization} = user_fixture()

      Repo.insert(%Chat{
        organization: organization,
        id: "d285cb4d-1c74-46af-9e3e-6e04aca83ffa",
        name: "chat_1"
      })

      MessageProcessor.handle_messages([
        %{
          key: "add-member-to-chat-entity",
          value: get_json("test/support/messages/add-member-to-chat-entity.json")
        }
      ])

      Chats.get_member(%{
        chat_id: "d285cb4d-1c74-46af-9e3e-6e04aca83ffa",
        user_auth_key: user.auth_key
      })

      assert Chats.get_member(%{
               chat_id: "d285cb4d-1c74-46af-9e3e-6e04aca83ffa",
               user_auth_key: user.auth_key
             }).user_auth_key == user.auth_key
    end

    test "remove-members-from-chat-entity", %{} do
      {:ok, user, _organization} = user_fixture()

      MessageProcessor.handle_messages([
        %{
          key: "remove-members-from-chat-entity",
          value: get_json("test/support/messages/remove-members-from-chat-entity.json")
        }
      ])

      assert Chats.get_member(%{
               chat_id: "d285cb4d-1c74-46af-9e3e-6e04aca83ffa",
               user_auth_key: user.auth_key
             }) == nil
    end
  end

  defp get_json(filename) do
    with {:ok, json_str} <- File.read(filename), do: json_str
  end
end
