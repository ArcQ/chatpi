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
            "containerReferenceId" => chat.container_reference_id
          }
        }
      })

    Kaffe.Producer.produce_sync(System.get_env("TOPIC_CHAT_OUT"), [
      {"created-chat", value}
    ])
  end
end
