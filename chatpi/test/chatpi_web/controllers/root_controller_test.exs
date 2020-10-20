defmodule ChatpiWeb.RootControllerTest do
  @moduledoc false
  use ChatpiWeb.ConnCase

  alias Chatpi.Users

  describe "index" do
    test "lists all users", %{conn: conn} do
      conn = get(conn, "/api/")
      assert json_response(conn, 200) == %{"status" => "ok"}
    end
  end
end
