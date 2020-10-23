defmodule ChatpiWeb.MessageProcessorTest do
  @moduledoc false

  import Mock
  use Chatpi.DataCase
  use Chatpi.Fixtures, [:user, :chat, :message]
  alias Chatpi.MessageProcessor
  alias Chatpi.{Users, Chats}
  import Chatpi.FixtureConstants

  setup_with_mocks([
    {Kaffe.Producer, [], [produce_sync: fn key, event -> "" end]}
  ]) do
    :ok
  end

  describe "handle_message" do
    test "upsert-user", %{} do
      # MessageProcessor.handle_messages([
      #   %{
      #     key: "upsert-user",
      #     value:
      #       "{\"publisher\":\"touchbase\",\"publishedAt\":\"2020-10-21T00:08:07.310812\",\"data\":{\"entity\":{\"creator\":{\"createdAt\":\"2020-08-08T00:00:00\",\"updatedAt\":\"2020-10-07T02:09:34.397919\",\"id\":\"40e6215d-b5c6-4896-987c-f30f3678f608\",\"authKey\":\"129830df-f45a-46b3-b766-2101db28ea62\",\"username\":\"arcq\",\"email\":\"eddielaw29d6@gmail.com\",\"score\":0.0,\"firstName\":\"eddie\",\"lastName\":\"law\",\"imageUrl\":\"https://images.unsplash.com/photo-1601924264473-30bdbcc48489?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2000&q=80\"},\"name\":\"testbase940\",\"score\":0.0,\"imageUrl\":\"https://source.unsplash.com/random\",\"members\":[{\"user\":{\"createdAt\":\"2020-08-08T00:00:00\",\"updatedAt\":\"2020-10-07T02:09:34.397919\",\"id\":\"40e6215d-b5c6-4896-987c-f30f3678f608\",\"authKey\":\"129830df-f45a-46b3-b766-2101db28ea62\",\"username\":\"arcq\",\"email\":\"eddielaw29d6@gmail.com\",\"score\":0.0,\"firstName\":\"eddie\",\"lastName\":\"law\",\"imageUrl\":\"https://images.unsplash.com/photo-1601924264473-30bdbcc48489?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=2000&q=80\"},\"role\":\"ADMIN\"}],\"active\":true}}}"
      #   }
      # ])

      # assert Users.list_users() |> length == 4
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
