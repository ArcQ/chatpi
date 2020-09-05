defmodule Chatpi.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :text, :text
      add :user_id, references(:users, column: :auth_id, type: :string, on_delete: :nothing, on_update: :update_all)
      add :chat_id, references(:chats, type: :uuid, on_delete: :nothing, on_update: :update_all)
      add :seen_by_id, references(:users, type: :uuid, on_delete: :nothing), null: true, default: nil
      add :seen_at, :naive_datetime, null: true, default: nil

      timestamps()
    end

    create index(:messages, [:user_id])
    create index(:messages, [:chat_id])
    create index(:messages, [:seen_by_id])
  end
end
