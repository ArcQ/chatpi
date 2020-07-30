defmodule Chatpi.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :username, :string
      add :auth_id, :string
      add :is_inactive, :boolean, null: true, default: nil

      timestamps()
    end

    create unique_index(:users, [:auth_id])
  end
end
