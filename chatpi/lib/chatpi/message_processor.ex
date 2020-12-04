defmodule Chatpi.MessageProcessor do
  @moduledoc """
  process messages from kafka
  """
  alias Chatpi.{Users, Chats, Messages}
  require Logger

  defp handle_message("upsert-user", %{user: user_attr}) do
    Logger.info("MessageProcessor upserting user")
    Cachex.del(:users_cache, user_attr.auth_key)
    Users.create_or_update_user(user_attr)
  end

  defp handle_message("upsert-chat-entity", %{entity: chat_attr}) do
    Logger.info("MessageProcessor upserting chat")

    if Map.has_key?(chat_attr, :id) do
      Cachex.del(:chats_cache, chat_attr.chat_id)
      # TODO update chats
    else
      Chats.create_chat_with_members(%{
        name: chat_attr.name,
        members: Enum.map(chat_attr.members, & &1.user.auth_key)
      })
    end
  end

  defp handle_message("add-member-to-chat-entity", %{entity: user_attr}) do
    Chats.add_chat_members(user_attr)
  end

  defp handle_message("remove-member-from-chat-entity", %{entity: user_attr}) do
    Chats.remove_chat_members(user_attr)
  end

  defp handle_message("add-system-message", %{entity: system_message}) do
    Messages.create_message(%{system_message | is_system: true})
  end

  # note only works for trusted clients right now
  def handle_messages(messages) do
    for %{key: key, value: value} = _message <- messages do
      {:ok, decoded_map} = Jason.decode(value)

      params = recursively_format_message(decoded_map)

      Logger.info("Message Received -> #{key}: #{inspect(params)}")
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
