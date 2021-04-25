defmodule Chatpi.MessagePublisher do
  @moduledoc """
  process messages from kafka
  """
  require Logger
  require Poison

  # defstruct [:data, :entity, :chat_id]

  def publish("created-chat", chat) do
    Logger.info("MessagePublisher produce message: " <> inspect(chat))

    value =
      Poison.encode!(%{
        "data" => %{
          "entity" => %{
            "chatId" => chat.id,
            "containerReferenceId" =>
              case Map.has_key?(chat, :container_reference_id) do
                true -> chat.container_reference_id
                false -> nil
              end
          }
        }
      })

    Kaffe.Producer.produce_sync(System.get_env("TOPIC_CHAT_OUT"), [
      {"created-chat", value}
    ])
  end
end
