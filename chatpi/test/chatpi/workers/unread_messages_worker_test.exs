defmodule Chatpi.UnreadMessagesWorkerTest do
  use Chatpi.DataCase, async: false

  setup do
    consumer_pid = start_supervised!({Chatpi.UnreadMessagesWorker, nil})
    {:ok, consumer_pid: consumer_pid}
  end

  describe "UnreadMessagesWorker" do
    use Chatpi.Fixtures, [:organization, :user, :chat, :message]

    test "UnreadMessagesWorker should take chat_ids and update unread_messages for those chats",
         %{consumer_pid: consumer_pid} do
      {:ok, _user, chat, _message} = message_fixture()

      GenServer.call(UnreadMessagesWorkerGenServer, {:add_chats_to_update, chat.id}, 1)

      assert GenServer.call(UnreadMessagesWorkerGenServer, :get_chats_to_update) ==
               MapSet.new([chat.id])

      send(consumer_pid, :work)

      # assert GenServer.call(UnreadMessagesWorkerGenServer, :get_chats_to_update) |> MapSet.size() ==
      #          0
    end
  end
end
