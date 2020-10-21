defmodule ChatpiWeb.Api.V1.UserController do
  @moduledoc false
  use ChatpiWeb, :controller

  alias Chatpi.{Users}

  @doc false
  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.json", users: users)
  end
end
