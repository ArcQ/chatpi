defmodule Chatpi.Repo.Migrations.AlterChatAddIsInactive do
  use Ecto.Migration

  def change do
    alter table(:chat) do
      add(:is_inactive, :boolean, null: false, default: false)
    end
  end
end
