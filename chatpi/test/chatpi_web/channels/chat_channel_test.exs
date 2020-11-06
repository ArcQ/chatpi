defmodule ChatpiWeb.ChatChannelTest do
  @moduledoc false
  import Mock
  use ChatpiWeb.ChannelCase

  import Chatpi.FixtureConstants
  use Chatpi.Fixtures, [:user, :chat, :message]
  alias ChatpiWeb.UserSocket

  setup_with_mocks([
    {Chatpi.Auth.Token, [], [verify_and_validate: fn _token -> {:ok, %{sub: auth_key_c()}} end]}
  ]) do
    :ok
  end

  setup do
    {:ok, user, chat, message} = message_fixture()

    {:ok, _, socket} =
      UserSocket
      |> socket("private_room", %{some: :assign, user: user})
      |> subscribe_and_join(ChatpiWeb.ChatChannel, "chat:touchbase:" <> chat.id, %{
        "token" => auth_key_c()
      })

    {:ok, _, lobby_socket} =
      UserSocket
      |> socket("public_room", %{some: :assign, user: user})
      |> subscribe_and_join(ChatpiWeb.ChatChannel, "chat:touchbase:lobby", %{
        "token" => auth_key_c()
      })

    {:ok, socket: socket, lobby: lobby_socket, user: user, chat: chat, message: message}
  end

  test "ping private and lobby replies with status ok", %{socket: socket, lobby: lobby_socket} do
    ref = push(socket, "ping")
    assert_reply(ref, :ok)

    ref = push(lobby_socket, "ping")
    assert_reply(ref, :ok)
  end

  test "send text messages should work", %{user: user, socket: socket} do
    push(socket, "message:new", %{"text" => "test a message"})

    assert_broadcast(
      "message:new",
      %{
        id: id,
        user_auth_key: user_auth_key,
        text: "test a message",
        inserted_at: inserted_at
      } = broadcasted_message
    )

    assert !Map.has_key?(broadcasted_message, :file)
    assert broadcasted_message[:user_auth_key] == user.auth_key
  end

  test "send reaction to a message should create new reaction if it does not exist", %{
    user: user,
    socket: socket,
    message: %{id: id}
  } do
    push(socket, "reaction:new", %{
      "message_id" => id,
      "reaction" => %{"classifier" => "laugh"}
    })

    assert_broadcast(
      "reaction:new",
      %{
        user_auth_key: user_auth_key,
        message_id: ^id,
        classifier: "laugh"
      } = broadcasted_message
    )

    assert user_auth_key == user.auth_key
  end

  test "send reply to a message should work", %{
    user: user,
    chat: chat,
    socket: socket,
    message: %{id: message_id}
  } do
    push(socket, "message:new", %{"text" => "test a message"})

    assert_broadcast(
      "message:new",
      broadcasted_message
    )

    broadcasted_id = broadcasted_message.id

    push(socket, "message:new", %{
      "reply_target_id" => broadcasted_id,
      "text" => "replied to your message"
    })

    assert broadcasted_message.reply_target_id == nil

    assert_broadcast(
      "message:new",
      %{
        user_auth_key: user_auth_key,
        reply_target_id: ^broadcasted_id,
        text: "replied to your message"
      } = broadcasted_reply
    )

    assert broadcasted_message[:user_auth_key] == user.auth_key

    saved_reply_message = Chatpi.Messages.find_by_id(broadcasted_reply.id)

    assert saved_reply_message.reply_target_id == broadcasted_message.id
  end
end
