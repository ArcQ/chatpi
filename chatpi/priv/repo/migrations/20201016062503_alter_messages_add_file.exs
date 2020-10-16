defmodule Chatpi.Repo.Migrations.AlterMessagesAddFile do
  use Ecto.Migration

  def change do
    alter table(:message) do
      add(:reply_target_id, references(:message, type: :uuid))
      add(:is_inactive, :boolean, null: true, default: nil)
    end

    create table(:message_file, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:message, references(:message, type: :uuid))
      add(:file, references(:file, type: :uuid))
    end

    create(index(:message_file, [:message]))
  end
end
