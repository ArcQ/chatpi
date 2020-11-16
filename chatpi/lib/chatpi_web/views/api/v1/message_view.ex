defmodule ChatpiWeb.Api.V1.MessageView do
  use ChatpiWeb, :view
  use Timex

  @public_attributes ~W(id text user_auth_key inserted_at reply_target_id custom_details)a

  def render("index.json", %{messages: messages}) do
    %{
      messages: render_many(messages, ChatpiWeb.Api.V1.MessageView, "message.json")
    }
  end

  def render("show.json", %{message: message}) do
    %{message: render_one(message, ChatpiWeb.Api.V1.MessageView, "message.json")}
  end

  def render("message.json", %{message: message}) do
    message
    |> Map.take(@public_attributes)

    # |> Map.replace!("files", &render_many(&1, ChatpiWeb.Api.V1.MessageView, "file.json"))
  end

  def render("file.json", %{url: url}) do
    url
  end
end
