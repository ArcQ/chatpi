defmodule Chatpi.OrganizationsTest do
  use Chatpi.DataCase

  alias Chatpi.Organizations
  alias Bcrypt

  describe "organizations" do
    alias Chatpi.Organizations.Organization

    @valid_attrs %{
      api_key: "some api key",
      api_secret_hash: Bcrypt.Base.hash_password("some api secret", Bcrypt.gen_salt(12, true)),
      name: "some org"
    }
    @update_attrs %{}

    def organization_fixture(attrs \\ %{}) do
      {:ok, organization} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Organizations.create_organization()

      organization
    end

    test "list_organizations/0 returns all organizations" do
      organization_fixture()
      assert Organizations.list_organizations() |> length == 2
    end

    test "get_organization!/1 returns the organization with given id" do
      organization = organization_fixture()
      assert Organizations.get_organization!(organization.id) == organization
    end

    test "get_organization_by_api_key_and_secret/2 returns the organization with given api key and validates" do
      organization = organization_fixture()

      assert Organizations.get_organization_by_api_key_and_validate(
               organization.api_key,
               "some api secret"
             ) == {:ok, organization}
    end

    test "create_organization/1 with valid data creates a organization" do
      assert {:ok, %Organization{} = organization} =
               Organizations.create_organization(@valid_attrs)
    end

    test "update_organization/2 with valid data updates the organization" do
      organization = organization_fixture()

      assert {:ok, %Organization{} = organization} =
               Organizations.update_organization(organization, @update_attrs)
    end

    test "delete_organization/1 deletes the organization" do
      organization = organization_fixture()
      assert {:ok, %Organization{}} = Organizations.delete_organization(organization)
      assert_raise Ecto.NoResultsError, fn -> Organizations.get_organization!(organization.id) end
    end

    test "change_organization/1 returns a organization changeset" do
      organization = organization_fixture()
      assert %Ecto.Changeset{} = Organizations.change_organization(organization)
    end
  end
end
