defmodule Chatpi.Repo.Migrations.CreateChatsMembers do
  use Ecto.Migration

  def change do
    create table(:chats_members) do
      add :chat_id, references(:chats, type: :uuid, on_delete: :delete_all, on_update: :update_all)
      add :user_id, references(:users, column: :auth_key, type: :string, on_delete: :delete_all, on_update: :update_all)
    end

    create index(:chats_members, [:chat_id])
    create index(:chats_members, [:user_id])
  end
end
