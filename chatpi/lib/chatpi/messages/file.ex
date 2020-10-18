defmodule Chatpi.Messages.File do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "file" do
    field(:url, :string)
    belongs_to(:message, Chatpi.Messages.Message)

    timestamps()
  end

  @doc false
  def changeset(member, attrs) do
    member
    |> cast(attrs, [:message_id])
    |> validate_required([:message_id])
  end
end
