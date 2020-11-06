defmodule ChatpiWeb.MessageProcessorTest do
  @moduledoc false

  import Mock
  use Chatpi.DataCase
  use Chatpi.Fixtures, [:user, :chat, :message]
  alias Chatpi.MessageProcessor
  alias Chatpi.{Users, Chats}

  setup_with_mocks([
    {Kaffe.Producer, [], [produce_sync: fn _key, _event -> "" end]}
  ]) do
    :ok
  end

  describe "handle_message" do
    test "upsert-user", %{} do
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
      {:ok, user} = user_fixture()

      MessageProcessor.handle_messages([
        %{
          key: "upsert-chat-entity",
          value: get_json("test/support/messages/upsert-chat-entity.json")
        }
      ])

      assert user.auth_key |> Chats.list_chats_for_user() |> length == 1
    end
  end

  defp get_json(filename) do
    with {:ok, json_str} <- File.read(filename), do: json_str
  end
end
