defmodule Chatpi.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organization, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:api_key, :string)
      add(:api_secret, :string)

      add(
        :admin_auth_key,
        references(:chatpi_user,
          column: :auth_key,
          type: :string,
          on_delete: :nothing,
          on_update: :update_all
        )
      )

      timestamps()
    end

    create table(:admin, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:reference_name, :string, null: false)

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

      # optional
      add(
        :user_auth_key,
        references(:chatpi_user,
          column: :auth_key,
          type: :string,
          on_delete: :nothing,
          on_update: :update_all
        )
      )

      timestamps()
    end

    create(index(:organization, [:api_key]))

    alter table(:message) do
      add(:is_system, :boolean, default: false)
    end
  end
end
