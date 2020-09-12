defmodule Chatpi.Repo.Migrations.CreateChatMember do
  use Ecto.Migration

  def change do
    create table(:chat_member) do
      add(
        :chat_id,
        references(:chat, type: :uuid, on_delete: :delete_all, on_update: :update_all)
      )

      add(
        :user_id,
        references(:chatpi_user,
          column: :auth_key,
          type: :string,
          on_delete: :delete_all,
          on_update: :update_all
        )
      )
    end

    create(index(:chat_member, [:chat_id]))
    create(index(:chat_member, [:user_id]))
  end
end
