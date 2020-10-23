defmodule Chatpi.UsersTest do
  use Chatpi.DataCase

  alias Chatpi.Users

  describe "messages" do
    import Chatpi.FixtureConstants

    use Chatpi.Fixtures, [:user]

    test "list_users/1 returns all messages" do
      {:ok, user} = user_fixture()

      assert Users.list_users() |> length == 4
    end

    test "list_users_by_ids/2 returns all messages" do
      {:ok, user} = user_fixture()

      assert Users.list_users_by_ids([auth_key_c()]) == [user]
    end

    test "create_user/1 with valid data creates user" do
      assert Users.list_users() |> length == 3

      assert {:ok, user} =
               Users.create_user(%{
                 auth_key: auth_key_c(),
                 username: "new_username"
               })

      assert Users.list_users() |> length == 4
    end

    test "create_or_update_user/2 creates or updates user" do
      assert {:ok, user} =
               Users.create_or_update_user(%{
                 auth_key: auth_key_c(),
                 username: "new_username"
               })

      id = user.id
      assert user.username == "new_username"

      assert {:ok, updated_user} =
               Users.create_or_update_user(%{
                 username: "blah",
                 is_inactive: false,
                 auth_key: auth_key_c()
               })

      assert updated_user.username == "blah"
      assert updated_user.id == id
    end

    test "update_user/2 updates user" do
      {:ok, user} = user_fixture()

      assert {:ok, user} =
               Users.update_user(user, %{
                 username: "blah",
                 is_inactive: false,
                 auth_key: auth_key_c()
               })

      assert user.username == "blah"
    end

    test "set_user_inactive makes it inactive" do
      {:ok, user} = user_fixture()

      assert {:ok, user} = Users.set_user_inactive(user.id)
      assert user.is_inactive == true
    end

    test "change_message/1 returns a message changeset" do
      {:ok, user} = user_fixture()

      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
