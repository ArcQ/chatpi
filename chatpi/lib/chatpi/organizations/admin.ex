defmodule Chatpi.Organizations.Admin do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field(:reference_name, :string)
    has_many(:organization_id, Chatpi.Organizations.Organization, foreign_key: :id)
    field(:api_secret, :string)

    belongs_to(:user_auth_key, Chatpi.Users.User, type: :string)

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [])
    |> validate_required([])
  end
end
