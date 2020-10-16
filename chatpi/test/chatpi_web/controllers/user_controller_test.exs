defmodule ChatpiWeb.UserControllerTest do
  @moduledoc false
  use ChatpiWeb.ConnCase

  alias Chatpi.Users

  @create_attrs %{auth_key: "129830df-f45a-46b3-b766-2101db28ea62", username: "some name"}

  @update_attrs %{
    auth_key: "some updated auth_key",
    username: "some updated name"
  }
  @invalid_attrs %{auth_key: nil, username: nil}

  def fixture(:user) do
    {:ok, user} = Users.create_user(@create_attrs)
    user
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, Routes.user_path(conn, :index))
      assert json_response(conn, 200) =~ "Listing Users"
    end
  end

  describe "create user" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_path(conn, :show, id)

      conn = get(conn, Routes.user_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_path(conn, :create), user: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User"
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end)
    end
  end

  defp create_user(_) do
    user = fixture(:user)
    {:ok, user: user}
  end
end
