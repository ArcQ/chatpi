defmodule ChatpiWeb.Api.V1.UserController do
  @moduledoc false
  use ChatpiWeb, :controller

  alias Chatpi.{Users}

  @doc false
  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.json", users: users)
  end

  def add_push_token(%Plug.Conn{body_params: %{type: token_type, token: token}} = conn, %{
        "chat_id" => chat_id,
        "type" => type,
        "message" => msg
      }) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    case token_type do
      "expo" ->
        nil
    end

    TokenView.render(conn, "show.json", %{})
  end
end
