defmodule ChatpiWeb.RootControllerTest do
  @moduledoc false
  use ChatpiWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert json_response(conn, 200)["status"] =~ "ok"
  end
end
