defmodule Chatpi.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organization, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:name, :string)
      add(:api_key, :string)
      add(:api_secret, :string)

      timestamps()
    end

    create(index(:organization, [:api_key]))

    alter table(:message) do
      add(:is_system, :boolean, default: false)
    end
  end
end
