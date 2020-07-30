defmodule ChatpiWeb.Api.V1.ChatView do
  use ChatpiWeb, :view
  use Timex

  @public_attributes ~W(id name)a
  @base_attributes ~W(id name)a

  def render("index.json", %{chats: chats}) do
    %{
      chats:
        Enum.map(chats, fn chat -> render_one(chat, ChatpiWeb.Api.V1.ChatView, "chat.json") end)
    }
  end

  def render("show.json", %{chat: chat}) do
    %{chat: render_one(chat, ChatpiWeb.Api.V1.ChatView, "chat.json")}
  end

  def render("chat.json", %{chat: chat}) do
    chat
    |> Map.take(@public_attributes)
  end

  def render("modified_chat.json", %{chat: chat}) do
    chat
    |> Map.take(@base_attributes)
  end
end
