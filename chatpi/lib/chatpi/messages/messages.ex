defmodule Chatpi.Messages.Cursor do
  @moduledoc """
  cusor for querying messages
  """
  defstruct query_type: "after", inserted_at: "2020-09-12T05:29:57"
  # field :bar, type: Bar
end

defmodule Chatpi.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.{Repo, Messages.Message, Chats.Chat}

  defp query_messages_paged(query) do
    query
    |> order_by(desc: :inserted_at)
    |> preload([:files])
    |> limit(20)
    |> Repo.all()
  end

  def list_messages_by_chat_id(chat_id) do
    Message
    |> where([message], message.chat_id == ^chat_id)
    |> query_messages_paged
  end

  def list_messages_by_chat_id_query(
        chat_id,
        %Chatpi.Messages.Cursor{query_type: query_type, inserted_at: inserted_at}
      ) do
    query =
      case query_type do
        "after" ->
          Message
          |> where([message], message.inserted_at > ^inserted_at and message.chat_id == ^chat_id)

        _ ->
          Message
          |> where([message], message.inserted_at < ^inserted_at)
      end

    query
    |> join(:inner, [message], chat in Chat, on: chat.id == ^chat_id)
    |> query_messages_paged
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
