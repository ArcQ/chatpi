defmodule ChatpiWeb.ChatChannelTest do
  @moduledoc false
  use ChatpiWeb.ChannelCase
  alias ChatpiWeb.UserSocket

  setup do
    {:ok, _, socket} =
      ChatpiWeb.UserSocket
      |> socket("user_id", %{some: :assign})
      |> subscribe_and_join(ChatpiWeb.ChatChannel, "chat:lobby")

    {:ok, socket: socket}
  end
end
