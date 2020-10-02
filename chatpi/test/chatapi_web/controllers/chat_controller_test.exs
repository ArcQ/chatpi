defmodule ChatpiWeb.ChatControllerTest do
  @moduledoc false
  use ChatpiWeb.ConnCase

  alias Chatpi.Chats

  use Chatpi.Fixtures, [:user, :chat]

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
    test "deletes chosen user", %{conn: conn, user: user} do
      user = user_fixture()
      conn = delete(conn, Routes.user_path(conn, :delete, user))
      assert redirected_to(conn) == Routes.user_path(conn, :index)

      assert_error_sent(404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end)
    end
  end
end
