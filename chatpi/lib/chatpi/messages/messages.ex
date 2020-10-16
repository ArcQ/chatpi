defmodule Cursor do
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

  def list_messages_by_chat_id(chat_id) do
    Message
    |> where([message], message.chat_id == ^chat_id)
    |> order_by(desc: :inserted_at)
    |> preload([:files])
    |> limit(20)
    |> Repo.all()
  end

  def list_messages_by_chat_id_query(
        chat_id,
        %Cursor{query_type: query_type, inserted_at: inserted_at}
      ) do
    query =
      Message
      |> join(:inner, [message], chat in Chat, on: chat.id == ^chat_id)
      |> order_by(desc: :inserted_at)
      |> preload([:files])

    if query_type == "after" do
      query
      |> where([message], message.inserted_at > ^inserted_at and message.chat_id == ^chat_id)
      |> limit(20)
      |> Repo.all()
    else
      query
      |> where([message], message.inserted_at < ^inserted_at)
      |> limit(20)
      |> Repo.all()
    end
  end

  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end
end
