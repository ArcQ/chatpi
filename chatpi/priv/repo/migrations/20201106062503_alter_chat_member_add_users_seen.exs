defmodule Chatpi.Repo.Migrations.AlterChatAddUsersSeen do
  use Ecto.Migration

  def change do
    alter table(:chat_member) do
      add(
        :message_seen_id,
        references(:message, type: :uuid, on_delete: :delete_all, on_update: :update_all)
      )
    end
  end
end
