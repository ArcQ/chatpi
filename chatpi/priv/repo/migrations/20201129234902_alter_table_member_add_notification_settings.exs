defmodule Chatpi.Repo.Migrations.AlterTableMemberAddNotificationSettings do
  use Ecto.Migration

  def change do
    alter table(:chat_member) do
      add(:is_muted, :bool, default: false)
    end
  end
end
