defmodule ChatpiWeb.ChatChannel do
  @moduledoc false
  use ChatpiWeb, :channel
  alias ChatpiWeb.Presence
  alias Chatpi.{Chats, Messages}
  alias ChatpiWeb.Api.V1.MessageView
  alias Presence

  @doc false
  def join("chat:touchbase:lobby", _payload, socket) do
    if authorized?(socket, "touchbbase", "lobby") do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc false
  def join("chat:touchbase:" <> private_topic_id, _payload, socket) do
    if authorized?(socket, "touchbase", private_topic_id) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc false
  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    {:ok, _} =
      Presence.track(socket, "user:#{socket.assigns.user.auth_key}", %{
        isTyping: false
      })

    {:noreply, socket}
  end

  @doc false
  def handle_in("user:typing", %{"isTyping" => isTyping}, socket) do
    Presence.update(socket, socket.assigns.user.auth_key, %{
      isTyping: isTyping
    })

    {:noreply, socket}
  end

  @doc false
  def handle_in("message:new", %{"text" => text, "gif" => true}, socket) do
    user = get_in(socket.assigns, [:user])

    text = "#{text}\n" <> get_random_gif(text)

    create_message!(
      get_chat_id(socket),
      user,
      text
    )

    broadcast!(socket, "message:new", %{user: user, text: text})
  end

  @doc false
  def handle_in("message:new", message_payload, socket) do
    user = get_in(socket.assigns, [:user])

    if String.length(message_payload.text) > 0 do
      message =
        create_message!(
          get_chat_id(socket),
          user,
          message_payload.text,
          message_payload.file
        )

      broadcast!(socket, "message:new", MessageView.render("message.json", %{message: message}))
    end

    {:noreply, socket}
  end

  # @doc false
  # defp authorized?(%{"token" => token} = _payload) do
  #   if String.length(token) > 0, do: true, else: false
  # end

  defp authorized?(socket, _api_key, topic_id) do
    if topic_id == "lobby" do
      true
    else
      Chats.is_member(socket.assigns.user.auth_key, topic_id)
    end
  end

  @doc false
  defp get_random_gif(message) do
    giphy_url =
      "http://api.giphy.com/v1/gifs/translate?apikey=" <>
        System.get_env("GIPHY_API_TOKEN") <> "&s=" <> message

    case :hackney.get(giphy_url, [], "", follow_redirect: true) do
      {:ok, 200, _headers, client_ref} ->
        {:ok, response} = :hackney.body(client_ref)
        response = Jason.decode!(response)

        "<img width='200' src='#{response["data"]["images"]["fixed_width_small"]["url"]}'/>"

      _ ->
        raise "Sorry! An error occurred your gif could not be shown."
    end
  end

  defp get_chat_id(socket) do
    List.last(String.split(socket.topic, ":"))
  end

  @doc false
  defp create_message!(id, user, text, file \\ nil) do
    case Messages.create_message(%{
           text: text,
           file: file,
           user_id: user.auth_key,
           chat_id: id
         }) do
      {:ok, message} -> message
      {:error, reason} -> raise "Your message could not sent, because: " <> reason
    end
  end
end
