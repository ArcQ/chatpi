defmodule Chatpi.Repo.Migrations.AlterMessagesAddFile do
  use Ecto.Migration

  def change do
    alter table(:message) do
      add(:reply_target_id, references(:message, type: :uuid))
      add(:is_inactive, :boolean, null: true, default: nil)
      add(:reactions, {:array, :map}, default: [])
    end
  end
end
