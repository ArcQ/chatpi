defmodule Chatpi.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :file, :string
      add :message_id, references(:messages, type: :uuid, on_delete: :delete_all)

      timestamps()
    end

    create index(:files, [:message_id])
  end
end
