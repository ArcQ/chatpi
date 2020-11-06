defmodule Chatpi.MessagePublisher do
  @moduledoc """
  process messages from kafka
  """
  require Logger

  def publish("created-chat", chat) do
    Logger.info("MessagePublisher produce message: " <> inspect(chat))
    Kaffe.Producer.produce_sync("chatpi_out", [{"key", "created-chat"}, {"chat", chat}])
  end
end
