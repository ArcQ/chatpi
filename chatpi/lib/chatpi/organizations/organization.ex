defmodule Chatpi.Organizations.Organization do
  @moduledoc false

  use Chatpi.Schema
  import Ecto.Changeset

  schema "organization" do
    field(:name, :string)
    field(:api_key, :string)
    field(:api_secret, :string)

    has_many(:owner_user_auth_key, Chatpi.Users.User, foreign_key: :auth_key)

    timestamps()
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name, :api_key, :api_secret])
    # |> validate_required([:name, :api_key, :api_secret])
    |> validate_required([])
  end
end
