defmodule Chatpi.Messages.Cursor do
  @moduledoc """
  cusor for querying messages
  """
  defstruct after_timestamp: "2020-09-12T05:29:57", before_timestamp: nil, limit: 50
  # field :bar, type: Bar
end

defmodule Chatpi.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.{Repo, Messages.Message, Chats.Chat}

  defp query_messages_paged(result_limit) do
    fn query ->
      query
      |> order_by(desc: :inserted_at)
      |> preload([:files, :reply_target])
      |> limit(^result_limit)
      |> reverse_order
      |> Repo.all()
    end
  end

  def find_by_id(message_id) do
    Message
    |> preload([:files, :reply_target])
    |> Repo.get(message_id)
  end

  def list_messages_by_chat_id(chat_id) do
    Message
    |> where([message], message.chat_id == ^chat_id)
    |> query_messages_paged(50).()
  end

  def list_messages_by_chat_id_query(
        chat_id,
        %Chatpi.Messages.Cursor{} = cursor
      ) do
    after_timestamp = cursor.after_timestamp
    before_timestamp = cursor.before_timestamp

    query = Message

    query =
      if after_timestamp != nil do
        Message
        |> where([message], message.inserted_at > ^after_timestamp)
      else
        query
      end

    query =
      if before_timestamp != nil do
        query
        |> where([message], message.inserted_at < ^before_timestamp)
      else
        query
      end

    query
    |> where([message], message.chat_id == ^chat_id)
    |> join(:inner, [message], chat in Chat, on: chat.id == ^chat_id)
    |> query_messages_paged(cursor.limit).()
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  # TODO we could make this more generic for all array types
  def merge_into_reactions(existing_items \\ [], new_item) do
    if Enum.any?(existing_items, &(&1.user_id == new_item.user_id)) do
      Enum.map(existing_items, fn existing_item ->
        if existing_item.user_id == new_item.user_id do
          new_item
        else
          existing_item
        end
      end)
    else
      [new_item | existing_items]
    end
  end

  def upsert_reaction(message_id, %{user_id: _, classifier: _} = reaction) do
    message =
      Message
      |> where([message], message.id == ^message_id)
      |> Repo.all()
      |> List.first()

    reactions =
      message
      |> Map.get(:reactions)
      |> (&(&1 || [])).()
      |> merge_into_reactions(reaction)

    message
    |> Message.update_reactions_changeset(%{reactions: reactions})
    |> Repo.update()
  end

  def update_message(%Message{} = message, attrs) do
    message
    |> Message.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end
end
