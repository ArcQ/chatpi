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
    {:ok, user, chat} = chat_fixture()

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

    {:ok, socket: socket, lobby: lobby_socket, user: user, chat: chat}
  end

  test "ping private and lobby replies with status ok", %{socket: socket, lobby: lobby_socket} do
    ref = push(socket, "ping")
    assert_reply(ref, :ok)

    ref = push(lobby_socket, "ping")
    assert_reply(ref, :ok)
  end

  test "send text messages should work", %{socket: socket} do
    push(socket, "message:new", %{"text" => "test a message"})
    assert_broadcast("message:new", %{message: %{text: "test a message"}})
  end
end
