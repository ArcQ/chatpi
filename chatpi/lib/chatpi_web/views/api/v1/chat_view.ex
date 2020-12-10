defmodule ChatpiWeb.Api.V1.ChatView do
  use ChatpiWeb, :view
  use Timex

  @public_attributes ~W(id name)a
  @details_attributes ~W(id name members inserted_at)a
  @my_member_attributes ~W(message_seen_id unread_messages)a

  def render("index.json", %{chats: chats, user_auth_key: user_auth_key}) do
    %{
      chats: render_many(chats, ChatpiWeb.Api.V1.ChatView, "chat_with_details.json"),
      detail:
        Enum.map(
          chats,
          &render("my_chat_details.json", %{chat: &1, user_auth_key: user_auth_key})
        )
    }
  end

  def render("index.json", %{chats: chats}) do
    %{
      chats: render_many(chats, ChatpiWeb.Api.V1.ChatView, "chat.json")
    }
  end

  def render("show.json", %{chat: chat, user_auth_key: user_auth_key}) do
    %{
      chat: render_one(chat, ChatpiWeb.Api.V1.ChatView, "chat_with_details.json"),
      detail: render("my_chat_details.json", %{chat: chat, user_auth_key: user_auth_key})
    }
  end

  def render("show.json", %{chat: chat}) do
    %{
      chat: render_one(chat, ChatpiWeb.Api.V1.ChatView, "chat_with_details.json")
    }
  end

  def render("chat.json", %{chat: chat}) do
    chat
    |> Map.take(@public_attributes)
  end

  def render("chat_with_details.json", %{chat: chat}) do
    chat
    |> Map.take(@details_attributes)
    |> Map.put(
      :members,
      chat.members
      |> Enum.map(fn member -> member.user end)
      |> render_many(ChatpiWeb.Api.V1.UserView, "show.json")
    )
  end

  def render("my_chat_details.json", %{chat: chat, user_auth_key: user_auth_key}) do
    chat.members
    |> Enum.find(fn member -> member.user_auth_key == user_auth_key end)
    |> Map.take(@my_member_attributes)
  end
end
