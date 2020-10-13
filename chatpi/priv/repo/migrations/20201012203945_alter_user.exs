defmodule Chatpi.Repo.Migrations.AlterUser do
  use Ecto.Migration

  def change do
    alter table(:chatpi_user) do
      add(:is_admin, :boolean)
    end
  end
end
