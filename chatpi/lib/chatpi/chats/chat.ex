defmodule Chatpi.Chats.Chat do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "chat" do
    field(:name, :string)

    field(:container_reference_id, :string)

    field(:is_inactive, :boolean)

    has_many(:members, Chatpi.Chats.Member)

    belongs_to(:organization, Chatpi.Organizations.Organization, type: Ecto.UUID)

    timestamps()
  end

  @doc false
  def changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name, :container_reference_id])
    |> validate_required([:name])
    |> put_assoc(:members, attrs[:members])
    |> put_assoc(:organization, attrs[:organization])
  end

  @doc false
  def update_changeset(chat, attrs) do
    chat
    |> cast(attrs, [:name, :is_inactive])
    |> put_assoc(:members, attrs[:members] || chat.members)
  end
end
