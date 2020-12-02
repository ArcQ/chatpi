defmodule ChatpiWeb.Api.V1.ChatController do
  @moduledoc false
  use ChatpiWeb, :controller
  use Plug.ErrorHandler
  alias Chatpi.Chats
  import Plug.ErrorHandler

  @doc false
  def index(conn, _params) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    chats = Chats.list_chats_for_user(auth_key)
    render(conn, "index.json", chats: chats, user_auth_key: auth_key)
  end

  @doc false
  def create(conn, _params) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    Chats.create_chat_with_members(%{
      name: conn.body_params["name"],
      members: [auth_key, conn.body_params["users"]]
    })
  end

  def mute_chat(conn, _params) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    Chats.create_chat_with_members(%{
      is_muted: conn.body_params["is_muted"],
      members: [auth_key, conn.body_params["users"]]
    })
  end

  defp handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    json(conn, %{error: 500, reason: reason})
  end
end
