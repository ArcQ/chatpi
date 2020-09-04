defmodule Chatpi.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.Repo

  alias Chatpi.Messages.Message

  @doc """
  Returns the list of messages for a chat paginated

  ## Examples

      iex> list_messages_by_chat_id(chat_id)
      [%Message{}, ...]

  """
  def list_messages(chat_id, cursor) do
    [message_id, iso_date_time] = Base.decode64(cursor) |> String.split(",")
    date_time = Timex.parse!(iso_date_time, "{ISO:Extended}")
    Repo.all(
      from(m in Message,
        distinct: true,
        inner_join: c in assoc(m, :chats),
        where: c.id == ^chat_id or (c.inserted_at < ^date_time and m.id < ^message_id),
        order_by: [desc: :inserted_at, desc: :id])
    )
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
