defmodule Chatpi.MessageProducer do
  @moduledoc """
  process messages from kafka
  """

  @callback publish(String.t(), any) :: any
  def publish("created-chat", chat) do
    IO.puts("MessageProducer produce message: " <> inspect(chat))
    Kaffe.Producer.produce_sync("chatpi_out", [{"key", "created-chat"}, {"chat", chat}])
  end
end
