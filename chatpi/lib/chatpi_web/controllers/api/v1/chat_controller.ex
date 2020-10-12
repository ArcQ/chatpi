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

    users =
      [auth_key | user_ids]
      |> Users.list_users_by_ids()

    if length(users) == length(users) do
      {:ok, chat} = Chats.create_chat(%{name: name})

      members =
        users
        |> Enum.map(fn user -> %Chats.Member{user: user, chat: chat} end)

      {:ok, chat} =
        chat
        |> Chats.update_chat(%{members: Enum.concat(chat.members, members)})

      render(conn, "show.json", chat: chat)
    end
  end

  defp handle_errors(conn, %{kind: _kind, reason: reason, stack: _stack}) do
    json(conn, %{error: 500, reason: reason})
  end
end
