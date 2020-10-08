defmodule Chatpi.MessageProcessor do
  alias Chatpi.{Users, Chats}

  defp handle_message("upsert user", %{"data" => user_params}) do
    IO.puts("MessageProcessor upserting user")
    Users.create_or_update_user(user_params)
  end

  def handle_messages(messages) do
    for %{key: key, value: value} = _message <- messages do
      IO.puts("Message Received -> #{key}: #{value}")
      handle_message(key, value)
    end

    # Important!
    :ok
  end
end
