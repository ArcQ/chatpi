defmodule ChatpiWeb.Api.V1.ChatController do
  @moduledoc false
  use ChatpiWeb, :controller

  import Ecto.Query, only: [from: 2]
  alias Chatpi.Repo
  alias Chatpi.{Chats, Chats.Chat, Messages.Message, Users}

  @doc false
  def index(conn, _params) do
    auth_id = Guardian.Plug.current_resource(conn, []).auth_id

    chats = Chats.list_chats_for_user(auth_id)
    render(conn, "index.json", chats: chats)
  end

  @doc false
  def show(conn, %{"id" => id}) do
    chat = Chats.get_chat!(id)
    render(conn, "show.json", chat: chat)
  end

  @doc false
  def create(conn, _params) do
    auth_id = Guardian.Plug.current_resource(conn, []).auth_id
    user_ids = conn.body_params["users"]
    name = conn.body_params["name"]

    users = [auth_id | user_ids] |> Users.list_users_by_ids()
    if length(users) == length(users) do
      case Chats.create_chat(%{users: users, name: name}) do
        {:ok, chat} ->
          render(conn, "modified_chat.json", chat: chat)

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "show.json", changeset: changeset)
      end
    end
  end

  @doc false
  def messages(conn, %{"id" => id}) do
    messages_query =
      from(m in Message, order_by: [desc: :inserted_at], limit: 10, preload: [:file])

    chats =
      Repo.all(
        from(c in Chat,
          distinct: true,
          join: p in assoc(c, :members),
          left_join: u1 in assoc(c, :users),
          where: u1.id == ^conn.assigns[:current_user].id and c.id == ^id,
          limit: 1,
          preload: [members: p, messages: ^messages_query]
        )
      )

    if length(chats) > 0 do
      chat = List.first(chats)

      members =
        Chatpi.Repo.all(
          from(
            p in Chatpi.Chats.Member,
            join: u in assoc(p, :user),
            where:
              p.chat_id == ^chat.id and
                p.user_id != ^conn.assigns[:current_user].id,
            limit: 1,
            preload: [user: u]
          )
        )

      receiver = List.first(members).user

      render(conn, "show.html",
        chat: chat,
        receiver: receiver,
        messages: chat.messages |> Enum.reverse()
      )
    else
      conn
      |> put_flash(:error, "You are not in this chat!")
      |> redirect(to: Routes.user_path(conn, :index))
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
end
