defmodule Chatpi.Repo.Migrations.AddChatContainerReferenceId do
  use Ecto.Migration

  def change do
    alter table(:chat) do
      add(
        :container_reference_id,
        :string,
        null: true
      )
    end
  end
end
