defmodule ChatpiWeb.ChatChannelTest do
  @moduledoc false
  use ChatpiWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      socket(ChatpiWeb.UserSocket, "user_id", %{some: :assign})
      |> subscribe_and_join(ChatpiWeb.ChatChannel, "chat:lobby")

    {:ok, socket: socket}
  end
end
