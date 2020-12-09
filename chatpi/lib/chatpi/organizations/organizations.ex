defmodule Chatpi.Organizations do
  @moduledoc """
  The Organizations context.
  """

  alias Bcrypt
  import Ecto.Query, warn: false
  alias Chatpi.Repo

  alias Chatpi.Organizations.Organization

  def list_organizations do
    Repo.all(Organization)
  end

  def get_organization!(id), do: Repo.get!(Organization, id)

  def get_organization_by_api_key_and_validate(api_key, api_secret) do
    organization = Repo.get_by(Organization, api_key: api_key)

    if Bcrypt.verify_pass(api_secret, organization.api_secret_hash) do
      {:ok, organization}
    else
      {:error}
    end
  end

  def create_organization(attrs \\ %{}) do
    %Organization{}
    |> Organization.changeset(attrs)
    |> Repo.insert()
  end

  def update_organization(%Organization{} = organization, attrs) do
    organization
    |> Organization.changeset(attrs)
    |> Repo.update()
  end

  def delete_organization(%Organization{} = organization) do
    Repo.delete(organization)
  end

  def change_organization(%Organization{} = organization, attrs \\ %{}) do
    Organization.changeset(organization, attrs)
  end
end
