defmodule ChatpiWeb.Api.V1.MessageController do
  @moduledoc false
  use ChatpiWeb, :controller
  use Plug.ErrorHandler
  import Ecto.Query, only: [from: 2]
  alias Chatpi.Repo
  alias Chatpi.{Chats, Messages.Message, Messages}
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
        messages: Messages.list_messages_by_chat_id_query(chat_id, query_type, inserted_at)
      )
    else
      render(conn, "index.json", messages: [])
    end
  end

  @doc false
  def index(conn, %{"chat_id" => chat_id}) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    if Chats.is_member(auth_key, chat_id) do
      render(conn, "index.json", messages: Messages.list_messages_by_chat_id(chat_id))
    else
      render(conn, "index.json", messages: [])
    end
  end

  def messages_seen(conn, %{"id" => id}) do
    if conn.assigns[:user_signed_in?] do
      from(m in Message,
        join: c in assoc(m, :chat),
        where: c.id == ^id and is_nil(m.seen_at) and m.user_id != ^conn.assigns[:current_user].id
      )
      |> Repo.update_all(
        set: [
          seen_by_id: conn.assigns[:current_user].id,
          seen_at: NaiveDateTime.utc_now()
        ]
      )

      json(conn, %{ok: 200})
    else
      conn
      |> put_flash(:error, "You have to sign in before!")
      |> redirect(to: Routes.session_path(conn, :new))
    end
  end

  defp handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    json(conn, %{error: 500, reason: reason})
  end
end