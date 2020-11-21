defmodule Chatpi.Repo.Migrations.AlterUserAddExpoToken do
  use Ecto.Migration

  def change do
    alter table(:chatpi_user) do
      add(:push_tokens, {:array, :map}, default: [])
    end
  end
end
