defmodule Chatpi.MessageProcessor do
  @moduledoc """
  process messages from kafka
  """
  alias Chatpi.{Users, Chats}

  defp handle_message("upsert-user", %{user: user_attr}) do
    IO.puts("MessageProcessor upserting user")
    Users.create_or_update_user(user_attr)
  end

  defp handle_message("upsert-chat-entity", %{entity: chat_attr}) do
    IO.puts("MessageProcessor upserting chat")

    Chats.create_chat_with_members(%{
      name: chat_attr.name,
      members: Enum.map(chat_attr.members, & &1.user.auth_key)
    })
  end

  defp handle_message("add-member-to-chat-entity", %{entity: user_attr}) do
    Chats.add_chat_members(user_attr)
  end

  defp handle_message("remove-member-from-chat-entity", %{entity: user_attr}) do
    Chats.remove_chat_members(user_attr)
  end

  def handle_messages(messages) do
    for %{key: key, value: value} = _message <- messages do
      {:ok, decoded_map} = Jason.decode(value)

      IO.puts("Message Received -> #{key}: #{inspect(messages)}")
      params = recursively_format_message(decoded_map)

      IO.puts("Message Received -> #{key}: #{inspect(params)}")
      handle_message(key, params.data)
    end

    :ok
  end

  defp recursively_format_message(message_map) do
    for {key, value} <- message_map,
        into: %{},
        do: {
          key
          |> Macro.underscore()
          |> String.to_atom(),
          cond do
            is_map(value) ->
              recursively_format_message(value)

            is_list(value) ->
              for v <- value do
                recursively_format_message(v)
              end

            true ->
              value
          end
        }
  end
end
