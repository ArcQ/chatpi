defmodule ChatpiWeb.Api.V1.MessageView do
  use ChatpiWeb, :view
  use Timex

  @public_attributes ~W(id text user_id chat_id inserted_at)a

  def render("index.json", %{messages: messages}) do
    %{
      messages:
        Enum.map(messages, fn message -> render_one(message, ChatpiWeb.Api.V1.MessageView, "message.json") end)
    }
  end

  def render("show.json", %{message: message}) do
    %{message: render_one(message, ChatpiWeb.Api.V1.MessageView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    message
    |> Map.take(@public_attributes)
  end
end
