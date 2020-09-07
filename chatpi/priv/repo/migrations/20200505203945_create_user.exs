defmodule Chatpi.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :username, :string
      add :auth_key, :string
      add :is_inactive, :boolean, null: true, default: nil

      timestamps()
    end

    create unique_index(:user, [:auth_key])
  end
end
