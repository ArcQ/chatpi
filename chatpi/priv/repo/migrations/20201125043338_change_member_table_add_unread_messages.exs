defmodule Chatpi.Repo.Migrations.ChangeMemberTableAddUnreadMessages do
  use Ecto.Migration

  def change do
    alter table(:chat_member) do
      add(:unread_messages, :integer, default: [])
    end
  end
end
