defmodule ChatpiWeb.Api.V1.ChatController do
  @moduledoc false
  use ChatpiWeb, :controller
  use Plug.ErrorHandler
  alias Chatpi.{Chats, Users}
  import Plug.ErrorHandler

  @doc false
  def index(conn, _params) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key

    chats = Chats.list_chats_for_user(auth_key)
    render(conn, "index.json", chats: chats)
  end

  @doc false
  def show(conn, %{"id" => id}) do
    chat = Chats.get_chat(id)
    render(conn, "show.json", chat: chat)
  end

  @doc false
  def create(conn, _params) do
    auth_key = Guardian.Plug.current_resource(conn, []).auth_key
    user_ids = conn.body_params["users"]
    name = conn.body_params["name"]

    users = [auth_key | user_ids] |> Users.list_users_by_ids()

    if length(users) == length(users) do
      case Chats.create_chat(%{users: users, name: name}) do
        {:ok, chat} ->
          render(conn, "modified_chat.json", chat: chat)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "show.json", changeset: changeset)
      end
    end
  end

  defp handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    json(conn, %{error: 500, reason: reason})
  end
end
