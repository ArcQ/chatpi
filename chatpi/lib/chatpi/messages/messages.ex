defmodule Chatpi.Messages.Cursor do
  @moduledoc """
  cusor for querying messages
  """
  defstruct query_type: "after", inserted_at: "2020-09-12T05:29:57"
  # field :bar, type: Bar
end

defmodule Chatpi.Messages.Reaction do
  @moduledoc """
  cusor for querying messages
  """
  defstruct [:user_id, :inserted_at, :classifier]
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

  def upsert_reaction(message_id, %Chatpi.Messages.Reaction{} = _) do
    Message
    |> where([message], message.message_id == ^message_id)
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
