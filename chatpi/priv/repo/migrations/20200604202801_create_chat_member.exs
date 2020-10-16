defmodule Chatpi.Repo.Migrations.CreateChatMember do
  use Ecto.Migration

  def change do
    create table(:chat_member, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(
        :chat_id,
        references(:chat, type: :uuid, on_delete: :delete_all, on_update: :update_all)
      )

      add(
        :user_auth_key,
        references(:chatpi_user,
          column: :auth_key,
          type: :string,
          on_delete: :delete_all,
          on_update: :update_all
        )
      )
    end

    create(index(:chat_member, [:chat_id, :user_auth_key]))
  end
end
