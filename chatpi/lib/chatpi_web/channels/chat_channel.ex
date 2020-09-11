defmodule ChatpiWeb.ChatChannel do
  @moduledoc false
  use ChatpiWeb, :channel
  alias ChatpiWeb.Presence
  alias Chatpi.{Chats, Messages}
  alias ChatpiWeb.Api.V1.MessageView

  @doc false
  def join("chat:lobby", payload, socket) do
    if authorized?(socket, "lobby") do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc false
  def join("chat:" <> private_topic_id, payload, socket) do
    if authorized?(socket, private_topic_id) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc false
  def handle_info(:after_join, socket) do
    Presence.track(socket, socket.assigns.user.id, %{
      typing: false,
      name: socket.assigns.user.username
    })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @doc false
  def handle_in("user:typing", %{"typing" => typing}, socket) do
    Presence.update(socket, socket.assigns.user.id, %{
      typing: typing,
      name: socket.assigns.user.username
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
  def handle_in("message:new", %{"text" => text}, socket) do
    user = get_in(socket.assigns, [:user])
    IO.puts inspect user

    if String.length(text) > 0 do
      message = create_message!(
        get_chat_id(socket),
        user,
        text
      )

      broadcast!(socket, "message:new", MessageView.render("message.json", %{message: message}))
    end

    {:noreply, socket}
  end

  @doc false
  def handle_in("file:new", %{"file_id" => file_id}, socket) do
    file = Chatpi.Uploads.get_file!(file_id)

    broadcast!(socket, "file:new", %{
      user: get_in(socket.assigns, [:user]),
      file: %{
        file_name: file.file.file_name,
        file_url: Chatpi.File.url({file.file.file_name, file}, signed: true)
      }
    })

    {:noreply, socket}
  end

  # @doc false
  # defp authorized?(%{"token" => token} = _payload) do
  #   if String.length(token) > 0, do: true, else: false
  # end

  defp authorized?(socket, topic_id) do
    true
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
  defp create_message!(id, user, text) do
    IO.puts inspect user
    case Messages.create_message(%{
           text: text,
           user_id: user.auth_key,
           chat_id: id
         }) do
      {:ok, message} -> message
      {:error, reason} -> raise "Your message could not sent, because: " <> reason
    end
  end
end
