defmodule Chatpi.Repo.Migrations.CreateChatsMembers do
  use Ecto.Migration

  def change do
    create table(:chats_members) do
      add :chat_id, references(:chats, type: :uuid, on_delete: :nothing)
      add :user_id, references(:users, type: :uuid, on_delete: :nothing)
    end

    create index(:chats_members, [:chat_id])
    create index(:chats_members, [:user_id])
  end
end
