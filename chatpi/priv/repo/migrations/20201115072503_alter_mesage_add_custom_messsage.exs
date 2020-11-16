defmodule Chatpi.Repo.Migrations.AlterMessageAddCustomMessage do
  use Ecto.Migration

  def change do
    alter table(:message) do
      add(:custom_details, :map, null: true)
    end
  end
end
