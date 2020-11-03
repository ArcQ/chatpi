defmodule Chatpi.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:message, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:text, :text)

      add(
        :user_auth_key,
        references(:chatpi_user,
          column: :auth_key,
          type: :string,
          on_delete: :nothing,
          on_update: :update_all
        )
      )

      add(:chat_id, references(:chat, type: :uuid, on_delete: :nothing, on_update: :update_all))

      timestamps()
    end

    create(index(:message, [:user_auth_key]))
    create(index(:message, [:chat_id]))
  end
end
