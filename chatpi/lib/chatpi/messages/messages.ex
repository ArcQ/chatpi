defmodule Chatpi.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.{Repo, Messages.Message, Chats.Chat}

  @doc """
  Returns the list of messages for a chat paginated with cursor

  ## Examples

  iex> list_messages_by_chat_id(chat_id, cursor)
  [%Message{}, ...]

  """
  def list_messages_by_chat_id(chat_id) do
    Message
    |> where([message], message.chat_id == ^chat_id)
    |> order_by([desc: :inserted_at])
    |> preload([:file])
    |> limit(20)
    |> Repo.all
  end

  @doc """
  Returns the list of messages for a chat paginated with cursor

  ## Examples

  iex> list_messages_by_chat_id(chat_id, cursor)
  [%Message{}, ...]

  """
  def list_messages_by_chat_id_query(chat_id, query_type, inserted_at) do
    query = Message
            |> join(:inner, [message], chat in Chat, on: chat.id == ^chat_id)
            |> order_by([desc: :inserted_at])
            |> preload([:file])

    if query_type == "after" do
      query
      |> where([message], message.inserted_at > ^inserted_at)
      |> limit(20)
      |> Repo.all
    else
      query
      |> where([message], message.inserted_at < ^inserted_at)
      |> limit(20)
      |> Repo.all
    end
  end

  @doc """
  Creates a message.

  ## Examples

  iex> create_message(%{field: value})
  {:ok, %Message{}}

  iex> create_message(%{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a message.

  ## Examples

  iex> update_message(message, %{field: new_value})
  {:ok, %Message{}}

  iex> update_message(message, %{field: bad_value})
  {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Message.

  ## Examples

  iex> delete_message(message)
  {:ok, %Message{}}

  iex> delete_message(message)
  {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

  iex> change_message(message)
  %Ecto.Changeset{source: %Message{}}

  """
  def change_message(%Message{} = message) do
    Message.changeset(message, %{})
  end

end
