defmodule ChatpiWeb.Api.V1.MessageController do
  @moduledoc false
  use ChatpiWeb, :controller
  use Plug.ErrorHandler
  alias ChatpiWeb.Endpoint
  action_fallback(FallbackController)
  import Plug.ErrorHandler

  @doc false
  def index(conn, %{
        "chat_id" => chat_id,
        "query_type" => query_type,
        "inserted_at" => inserted_at
      }) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    if Chats.is_member(auth_key, chat_id) do
      render(conn, "index.json",
        messages:
          Messages.list_messages_by_chat_id_query(chat_id, %Cursor{
            query_type: query_type,
            inserted_at: inserted_at
          })
      )
    else
      render(conn, "index.json", messages: [])
    end
  end

  @doc false
  def create_system_message(conn, %{
        "chat_id" => chat_id,
        "auth_key" => auth_key,
        "event" => event,
        "message" => msg
      }) do
    admin = Guardian.Plug.current_resource(conn, [])

    if is_admin(chat_id, auth_key) do
      Endpoint.broadcast_from(admin.id, chat_id, event, msg)
    else
      %{error: "unauthorized"}
    end
  end

  defp is_admin(chat_id, auth_key) do
    chat_id == "testAdminChatId" and auth_key == "testAuthKey"
  end

  defp handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    json(conn, %{error: 500, reason: reason})
  end
end
