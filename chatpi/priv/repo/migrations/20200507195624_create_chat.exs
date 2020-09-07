defmodule Chatpi.Repo.Migrations.CreateChat do
  use Ecto.Migration

  def change do
    create table(:chat, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :name, :string

      timestamps()
    end
  end
end
