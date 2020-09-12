defmodule ChatpiWeb.Api.V1.ChatView do
  use ChatpiWeb, :view
  use Timex

  @public_attributes ~W(id name)a
  @details_attributes ~W(id name members inserted_at)a

  def render("index.json", %{chats: chats}) do
    %{
      chats: render_many(chats, ChatpiWeb.Api.V1.ChatView, "chat.json")
    }
  end

  def render("show.json", %{chat: chat}) do
    %{chat: render_one(chat, ChatpiWeb.Api.V1.ChatView, "chat_with_details.json")}
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
      |> render_many(ChatpiWeb.Api.V1.UserView, "user.json")
    )
  end
end
