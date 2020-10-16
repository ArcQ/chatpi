defmodule Chatpi.Messages.File do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "file" do
    field(:url, :string)
    belongs_to(:message, Chatpi.Messages.Message)
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:chat_id, :user_auth_key])
    |> validate_required([:chat_id, :user_auth_key])
    |> put_change(:id, Ecto.UUID.bingenerate())
  end
end
