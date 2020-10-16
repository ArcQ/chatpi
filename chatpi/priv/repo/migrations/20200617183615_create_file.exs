defmodule Chatpi.Repo.Migrations.CreateFile do
  use Ecto.Migration

  def change do
    create table(:file, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:url, :string)

      add(
        :message_id,
        references(:message, type: :uuid, on_delete: :delete_all, on_update: :update_all)
      )

      timestamps()
    end

    create(index(:file, [:message_id]))
  end
end
