defmodule Chatpi.MessageProcessor do
  @moduledoc """
  process messages from kafka
  """
  alias Chatpi.{Users, Chats, Messages, Organizations}
  require Logger

  defp handle_message("upsert-user", %{organization: organization}, %{user: user_attr}) do
    Logger.info("MessageProcessor upserting user")
    Cachex.del(:users_cache, user_attr.auth_key)
    Users.create_or_update_user(Map.put(user_attr, :organization, organization))
  end

  defp handle_message("upsert-chat-entity", %{organization: organization}, %{entity: chat_attr}) do
    Logger.info("MessageProcessor upserting chat")

    if Map.has_key?(chat_attr, :id) do
      Cachex.del(:chats_cache, chat_attr.chat_id)
      # TODO update chats
    else
      Chats.create_chat_with_members(%{
        container_reference_id: chat_attr.container_reference_id,
        name: chat_attr.name,
        members: Enum.map(chat_attr.members, & &1.user.auth_key),
        organization: organization
      })
    end
  end

  defp handle_message("delete-chat-entity", %{organization: organization}, %{entity: chat_attr}) do
    Logger.info("MessageProcessor deleting chat")

    # TODO make chat inactive
    Chats.get_chat(chat_attr.chat_id)
    |> Chats.update_chat(%{is_inactive: true})
  end

  defp handle_message("add-member-to-chat-entity", context, %{
         entity: %{
           user_auth_key: user_auth_key,
           chat_id: chat_id
         }
       }) do
    Chats.add_chat_member(context.organization.id, %{
      user_auth_key: user_auth_key,
      chat_id: chat_id
    })
  end

  defp handle_message("remove-members-from-chat-entity", context, %{
         entity: %{
           users: users,
           chat_id: chat_id
         }
       }) do
    Chats.remove_chat_members(
      context.organization.id,
      chat_id,
      Enum.map(users, & &1.auth_key)
    )
  end

  defp handle_message("add-system-message", _context, %{entity: system_message}) do
    Messages.create_message(%{system_message | is_system: true})
  end

  # note only works for trusted clients right now
  def handle_messages(messages) do
    for %{key: key, value: value} = _message <- messages do
      {:ok, decoded_map} = Jason.decode(value)

      params = recursively_format_message(decoded_map)

      Logger.info("Message Received -> #{key}: #{inspect(params)}")

      case Organizations.get_organization_by_api_key_and_validate(
             params.data.api_key,
             params.data.api_secret
           ) do
        {:ok, organization} ->
          handle_message(key, %{organization: organization}, params.data)

        {:error} ->
          Logger.info(
            "Message Denied -> api_key: #{params.data.api_key}: could not be verified with api_secret #{
              params.data.api_secret
            }"
          )
      end
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
