defmodule ChatpiWeb.ChatChannel do
  @moduledoc false
  use ChatpiWeb, :channel
  alias ChatpiWeb.Presence
  alias Chatpi.{Chats, Messages}
  alias ChatpiWeb.Api.V1.MessageView
  alias Presence

  @doc false
  def join("chat:touchbase:lobby", socket) do
    if authorized?(socket, "touchbbase", "lobby") do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc false
  def join("chat:touchbase:" <> chat_id, %{"query" => query}, socket) do
    if authorized?(socket, "touchbase", chat_id) do
      send(self(), :after_join)

      response_payload = %{
        messages:
          Messages.list_messages_by_chat_id_query(chat_id, %Messages.Cursor{
            before_timestamp: query["before"],
            after_timestamp: query["after"]
          })
      }

      {:ok, response_payload, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc false
  def join("chat:touchbase:" <> chat_id, %{}, socket) do
    if authorized?(socket, "touchbase", chat_id) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @doc false
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, "user:#{socket.assigns.user.auth_key}", %{
        is_typing: false
      })

    push(socket, "presence_state", Presence.list(socket))

    {:noreply, socket}
  end

  @doc false
  def handle_in("user:typing", %{"is_typing" => is_typing}, socket) do
    Presence.update(socket, "user:#{socket.assigns.user.auth_key}", %{
      is_typing: is_typing
    })

    push(socket, "presence_diff", Presence.list(socket))

    {:noreply, socket}
  end

  @doc false
  def handle_in("read_message", %{"message_seen_id" => message_seen_id}, socket) do
    Presence.update(socket, socket.assigns.user.auth_key, %{
      read_message: message_seen_id
    })

    {:noreply, socket}
  end

  @doc false
  def handle_in("ping", _payload, socket) do
    {:reply, {:ok, %{status: "ok"}}, socket}
  end

  @doc false
  def handle_in(
        "reaction:new",
        %{
          "reaction_target_id" => message_id,
          "reaction" => %{
            "classifier" => classifier
          }
        },
        socket
      ) do
    user = get_in(socket.assigns, [:user])

    {:ok, _upserted_reaction} =
      Messages.upsert_reaction(
        message_id,
        %{user_id: user.id, classifier: classifier}
      )

    broadcast!(socket, "reaction:new", %{
      reaction_target_id: message_id,
      classifier: classifier,
      user_auth_key: user.auth_key
    })

    # {:noreply, socket} ? should we really need to ack this?
    {:reply, :ok, socket}
  end

  @doc false
  def handle_in("message:new", %{"text" => text, "gif" => true}, socket) do
    user = get_in(socket.assigns, [:user])

    text = "#{text}\n" <> get_random_gif(text)

    created_message =
      create_message!(
        get_chat_id(socket),
        user,
        text
      )

    broadcast!(socket, "message:new", %{created_message | user: user, text: text})

    Presence.update(socket, socket.assigns.user.auth_key, %{
      read_message: created_message.id
    })

    # {:noreply, socket} ? should we really need to ack this?
    {:reply, :ok, socket}
  end

  @doc false
  def handle_in("message:new", message_payload, socket) do
    user = get_in(socket.assigns, [:user])
    reply_target_id = message_payload["reply_target_id"] || nil

    case Messages.create_message(%{
           text: message_payload["text"],
           files: message_payload["files"],
           custom_details: message_payload["custom_details"],
           reply_target_id: reply_target_id,
           user_auth_key: user.auth_key,
           chat_id: get_chat_id(socket)
         }) do
      {:ok, message} ->
        broadcast!(
          socket,
          "message:new",
          MessageView.render("message.json", %{
            message: %{message | reply_target_id: reply_target_id}
          })
        )

        Presence.update(socket, socket.assigns.user.auth_key, %{
          read_message: message.id
        })

      {:error, reason} ->
        raise "Your message could not sent, because: " <> reason
    end

    # {:noreply, socket} ? should we really need to ack this?
    {:reply, :ok, socket}
  end

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
  defp create_message!(id, user, text \\ "", files) do
    case Messages.create_message(%{
           text: text,
           files: files,
           user_auth_key: user.auth_key,
           chat_id: id
         }) do
      {:ok, message} -> message
      {:error, reason} -> raise "Your message could not sent, because: " <> reason
    end
  end
end
