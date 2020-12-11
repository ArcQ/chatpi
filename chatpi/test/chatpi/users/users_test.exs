defmodule Chatpi.UsersTest do
  use Chatpi.DataCase

  alias Chatpi.{Users, Users.User}
  alias TestUtils

  describe "messages" do
    import Chatpi.FixtureConstants

    use Chatpi.Fixtures, [:organization, :user]

    setup do
      TestUtils.sql_sandbox_allow_pid(:users_cache)
    end

    test "list_users/1 returns all messages" do
      {:ok, _user, _organization} = user_fixture()

      assert Users.list_users() |> length == 4
    end

    # test "list_users_by_ids/2 returns all messages" do
    #   {:ok, user, _organization} = user_fixture()

    #   assert Users.list_users_by_ids([auth_key_c()]) == [user]
    # end

    test "get_user_by_auth_key_cached should save into cache if not exists, and get from cache if it exists" do
      {:ok, user, organization} = user_fixture()
      # user = Map.put(user, :organization, nil)
      # assert Users.get_user_by_auth_key_cached(user.auth_key) |> Map.put(:organization, nil) ==
      #          user

      # {:ok, cached_user} = Cachex.get(:users_cache, user.auth_key)

      # cached_user.
      expected_user = TestUtils.forget(user, :organization)

      assert Users.get_user_by_auth_key_cached(user.auth_key) == expected_user
      assert Cachex.get(:users_cache, user.auth_key) == {:ok, expected_user}
      Users.update_user(%User{id: user.id}, %{is_inactive: true})
      assert Users.get_user_by_auth_key(user.auth_key) == nil
      assert Users.get_user_by_auth_key_cached(user.auth_key) == expected_user
    end

    test "get_user_by_auth_key_and_org/1 should get user if org matches" do
      {:ok, user, organization} = user_fixture()

      assert {:ok, user} = Users.get_user_by_auth_key_and_org(user.auth_key, organization.id)
    end

    test "get_user_by_auth_key_and_org/1 should error if org doesn't match" do
      {:ok, user, organization} = user_fixture()

      assert {:error, error} = Users.get_user_by_auth_key_and_org(user.auth_key, user.id)
    end

    test "create_user/1 with valid data creates user" do
      {:ok, organization} = organization_fixture()

      assert Users.list_users() |> length == 3

      assert {:ok, user} =
               Users.create_user(%{
                 auth_key: auth_key_c(),
                 username: "new_username",
                 organization: organization
               })

      assert Users.list_users() |> length == 4
      assert user.is_inactive == false
    end

    test "create_or_update_user/2 creates or updates user" do
      {:ok, organization} = organization_fixture()

      assert {:ok, user} =
               Users.create_or_update_user(%{
                 auth_key: auth_key_c(),
                 username: "new_username",
                 organization: organization
               })

      id = user.id
      assert user.username == "new_username"

      assert {:ok, updated_user} =
               Users.create_or_update_user(%{
                 username: "blah",
                 is_inactive: false,
                 auth_key: auth_key_c(),
                 organization: organization
               })

      assert updated_user.username == "blah"
      assert updated_user.id == id
    end

    test "update_user/2 updates user" do
      {:ok, user, _organization} = user_fixture()

      assert {:ok, user} =
               Users.update_user(user, %{
                 username: "blah",
                 is_inactive: false,
                 auth_key: auth_key_c()
               })

      assert user.username == "blah"
    end

    test "update_user/2 won't allow updates to organizations" do
      {:ok, user, organization} = user_fixture()

      assert {:ok, user} =
               Users.update_user(user, %{
                 organization: nil
               })

      assert user.organization == organization
    end

    test "update_user set user inactive makes it inactive" do
      {:ok, user, _organization} = user_fixture()

      assert {:ok, user} = Users.update_user(%User{id: user.id}, %{is_inactive: true})
      assert user.is_inactive == true
    end

    test "change_message/1 returns a message changeset" do
      {:ok, user, _organization} = user_fixture()

      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
