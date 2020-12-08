defmodule Chatpi.Repo.Migrations.AddOrganizationsToTables do
  use Ecto.Migration

  def change do
    alter table(:chatpi_user) do
      add(
        :organization_id,
        references(:organization,
          column: :id,
          type: :uuid,
          on_delete: :delete_all,
          on_update: :update_all
        ),
        null: false
      )
    end

    alter table(:chat) do
      add(
        :organization_id,
        references(:organization,
          column: :id,
          type: :uuid,
          on_delete: :delete_all,
          on_update: :update_all
        ),
        null: false
      )
    end
  end
end
