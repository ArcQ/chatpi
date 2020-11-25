defmodule Chatpi.UnreadMessagesWorker do
  @moduledoc """
  Store chats that have changed and every x minutes update unread messages for all users in the chat

  """
  use GenServer
  # use Agent

  @interval 10

  def start_link(interval) do
    GenServer.start_link(
      __MODULE__,
      %{interval: interval || @interval * 60 * 1000, chats_to_update: MapSet.new()},
      name: UnreadMessagesWorkerGenServer
    )

    # chats_to_update = MapSet.new()
    # Agent.start_link(fn -> chats_to_update end, name: __MODULE__)
  end

  def add_chat_for_update do
    Agent.update(__MODULE__, &(&1 ++ 1))
  end

  def init(state) do
    schedule_work(state.interval)
    {:ok, state}
  end

  def handle_call(:get_chats_to_update, _from, state) do
    {:reply, state.chats_to_update, state}
  end

  def handle_call({:add_chats_to_update, chat_id}, _from, state) do
    state =
      state
      |> Map.update!(:chats_to_update, &MapSet.put(&1, chat_id))

    {:reply, :ok, state}
  end

  def handle_info(:work, state) do
    # state.chats_to_update
    # |> Enum.each(update_unread_messages)

    # Do Work then Reschedule once more
    schedule_work(state.interval)
    {:noreply, state}
  end

  defp schedule_work(interval) do
    Process.send_after(self(), :work, interval)
  end
end
