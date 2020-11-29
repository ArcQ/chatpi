defmodule ChatpiWeb.ChatChannelTest do
  @moduledoc false
  import Mock
  use ChatpiWeb.ChannelCase

  import Chatpi.FixtureConstants
  use Chatpi.Fixtures, [:user, :chat, :message]
  alias ChatpiWeb.UserSocket

  setup_with_mocks([
    {Chatpi.Auth.Token, [], [verify_and_validate: fn _token -> {:ok, %{sub: auth_key_c()}} end]},
    {ExponentServerSdk.PushNotification, [], [push_list: fn messages -> {:ok, messages} end]}
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

    TestUtils.sql_sandbox_allow_pid(:chats_cache)

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

    Process.sleep(50)
  end

  test "send reaction to a message should create new reaction if it does not exist", %{
    user: user,
    socket: socket,
    message: %{id: id}
  } do
    push(socket, "reaction:new", %{
      "reaction_target_id" => id,
      "reaction" => %{"classifier" => "laugh"}
    })

    assert_broadcast(
      "reaction:new",
      %{
        user_auth_key: user_auth_key,
        reaction_target_id: ^id,
        classifier: "laugh"
      } = broadcasted_message
    )

    assert user_auth_key == user.auth_key

    Process.sleep(50)
  end

  test "send reply to a message should work", %{
    user: user,
    socket: socket
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

    # temporary fix because broadcast pulls from cache in another process so we need to wait for that to finish
    Process.sleep(50)
  end

  test "broadcasting saves an entry of chats in the cache for broadcasting", %{
    chat: chat,
    socket: socket
  } do
    push(socket, "message:new", %{"text" => "test a message"})

    Process.sleep(50)

    {:ok, cached_chat} = Cachex.get(:chats_cache, chat.id)
    assert cached_chat.members |> length == 1
  end

  test "send messages with custom_details should work", %{user: _user, socket: socket} do
    push(socket, "message:new", %{
      "custom_details" => %{random_payload: "some value"}
    })

    assert_broadcast(
      "message:new",
      %{
        id: id,
        custom_details: custom_details,
        inserted_at: inserted_at
      } = broadcasted_message
    )

    assert custom_details["random_payload"] == "some value"

    saved_mesasge = Chatpi.Messages.find_by_id(id)

    assert saved_mesasge.custom_details["random_payload"] == "some value"
    assert called(ExponentServerSdk.PushNotification.push_list(:_))
  end

  test "broadcasting presence", %{socket: _socket, user: _user, chat: _chat} do
    assert_broadcast("presence_diff", %{
      joins: joins
    })

    assert joins |> Map.values() |> length == 1
    join_payload = joins |> Map.values() |> List.first() |> Map.get(:metas) |> List.first()

    assert %{
             is_typing: false,
             phx_ref: phx_ref
           } = join_payload
  end

  test "handles start and stop typing indicators on presence", %{
    socket: socket,
    user: user,
    chat: _chat
  } do
    push(socket, "user:typing", %{is_typing: true})

    ChatpiWeb.Presence.list(socket)

    assert socket
           |> ChatpiWeb.Presence.get_by_key("user:#{user.auth_key}")
           |> Map.get(:metas)
           |> List.first()
           |> Map.get(:is_typing) == true
  end

  test "join and subscribe with query for messages", %{user: user, chat: chat, message: message} do
    {:ok, response, _socket} =
      UserSocket
      |> socket("private_room", %{some: :assign, user: user})
      |> subscribe_and_join(ChatpiWeb.ChatChannel, "chat:touchbase:" <> chat.id, %{
        "token" => auth_key_c(),
        "query" => %{
          "before" =>
            message.inserted_at
            |> NaiveDateTime.add(100, :second)
            |> NaiveDateTime.to_iso8601()
        }
      })

    assert response.messages |> length == 1
    assert response.messages |> List.first() |> Map.get(:id) == message.id

    {:ok, response, _socket} =
      UserSocket
      |> socket("private_room", %{some: :assign, user: user})
      |> subscribe_and_join(ChatpiWeb.ChatChannel, "chat:touchbase:" <> chat.id, %{
        "token" => auth_key_c(),
        "query" => %{
          "after" =>
            message.inserted_at
            |> NaiveDateTime.add(-100, :second)
            |> NaiveDateTime.to_iso8601()
        }
      })

    assert response.messages |> length == 1
    assert response.messages |> List.first() |> Map.get(:id) == message.id

    {:ok, response, _socket} =
      UserSocket
      |> socket("private_room", %{some: :assign, user: user})
      |> subscribe_and_join(ChatpiWeb.ChatChannel, "chat:touchbase:" <> chat.id, %{
        "token" => auth_key_c(),
        "query" => %{
          "before" =>
            message.inserted_at
            |> NaiveDateTime.add(100, :second)
            |> NaiveDateTime.to_iso8601(),
          "after" =>
            message.inserted_at
            |> NaiveDateTime.add(-100, :second)
            |> NaiveDateTime.to_iso8601()
        }
      })

    assert response.messages |> length == 1
    assert response.messages |> List.first() |> Map.get(:id) == message.id
  end
end
