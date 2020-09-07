defmodule Chatpi.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:message, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :text, :text
      add :user_id, references(:user, column: :auth_key, type: :string, on_delete: :nothing, on_update: :update_all)
      add :chat_id, references(:chat, type: :uuid, on_delete: :nothing, on_update: :update_all)
      add :seen_by_id, references(:user, type: :uuid, on_delete: :nothing), null: true, default: nil
      add :seen_at, :naive_datetime, null: true, default: nil

      timestamps()
    end

    create index(:message, [:user_id])
    create index(:message, [:chat_id])
    create index(:message, [:seen_by_id])
  end
end
