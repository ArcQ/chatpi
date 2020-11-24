defmodule ChatpiWeb.Api.V1.UserController do
  @moduledoc false
  use ChatpiWeb, :controller

  alias Chatpi.{Users}

  action_fallback(ChatpiWeb.Api.V1.FallbackController)

  @doc false
  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.json", users: users)
  end

  def add_push_token(conn, _params) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key
    %{"type" => token_type, "token" => token, "device_id" => device_id} = conn.body_params

    {:ok, user} =
      case token_type do
        "expo" ->
          Users.add_push_token_by_auth_key(auth_key, %{
            token: token,
            device_id: device_id,
            type: token_type
          })
      end

    render(conn, "show.json", user: user)
  end
end
