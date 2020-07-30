defmodule Chatpi.Uploads.File do
  @moduledoc false

  use Chatpi.Schema
  use Arc.Ecto.Schema
  import Ecto.Changeset

  schema "files" do
    field(:file, Chatpi.File.Type)

    belongs_to(:message, Chatpi.Messages.Message)

    timestamps()
  end

  @doc false
  def changeset(file, params \\ %{}) do
    file
    |> cast(params, [:message_id])
    |> cast_attachments(params, [:file])
    |> validate_required([:file, :message_id])
  end
end
