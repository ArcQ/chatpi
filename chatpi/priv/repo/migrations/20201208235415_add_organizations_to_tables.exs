defmodule Chatpi.Repo.Migrations.AddOrganizationsToTables do
  use Ecto.Migration

  def change do
    alter table(:organization) do
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

    create(index(:organization, [:api_key]))
  end
end
