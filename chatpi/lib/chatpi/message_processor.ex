defmodule Chatpi.MessageProcessor do
  @moduledoc """
  process messages from kafka
  """
  alias Chatpi.{Users, Chats}

  defp handle_message("upsert-user", %{"user" => user_params}) do
    IO.puts("MessageProcessor upserting user")
    Users.create_or_update_user(user_params)
  end

  defp handle_message("upsert-chat-entity", %{"data" => user_params}) do
    Chats.create_chat(user_params)
  end

  defp handle_message("add-member-to-chat-entity", %{"data" => user_params}) do
    Chats.add_chat_members(user_params)
  end

  defp handle_message("remove-member-from-chat-entity", %{"data" => user_params}) do
    Chats.remove_chat_members(user_params)
  end

  def handle_messages(messages) do
    for %{key: key, value: value} = _message <- messages do
      IO.puts("Message Received -> #{key}: #{value}")
      handle_message(key, value.data)
    end

    # Important!
    :ok
  end
end
