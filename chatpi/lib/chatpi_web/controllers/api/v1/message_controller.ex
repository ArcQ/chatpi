defmodule ChatpiWeb.Api.V1.MessageController do
  @moduledoc false
  use ChatpiWeb, :controller
  use Plug.ErrorHandler
  alias Chatpi.{Chats, Messages}
  import Plug.ErrorHandler

  action_fallback(FallbackController)

  @doc """
  optionals:
  "before" => before_timestamp,
  "after" => after_timestamp
  """
  def index(
        conn,
        %{
          "chat_id" => chat_id
        } = params
      ) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    if Chats.is_member(auth_key, chat_id) do
      render(conn, "index.json",
        messages:
          Messages.list_messages_by_chat_id_query(chat_id, %Messages.Cursor{
            before_timestamp: params["before"],
            after_timestamp: params["after"]
          })
      )
    else
      render(conn, "index.json", messages: [])
    end
  end

  @doc "
  create system messages
  "
  def create(conn, %{
        "chat_id" => chat_id,
        "event" => event,
        "message" => msg
      }) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    if is_admin(conn, chat_id, auth_key) do
      ChatpiWeb.Endpoint.broadcast_from(auth_key, chat_id, event, msg)
    else
      %{error: "unauthorized"}
    end
  end

  defp is_admin(conn, _chat_id, _auth_key) do
    conn.req_headers["x-api-key"] == "test123"
  end

  defp handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    json(conn, %{error: 500, reason: reason})
  end
end
