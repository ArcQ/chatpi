defmodule ChatpiWeb.Api.V1.UserController do
  @moduledoc false
  use ChatpiWeb, :controller

  alias Chatpi.{Users}

  @doc false
  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.json", users: users)
  end

  @doc false
  def create(conn, %{"user" => user_params}) do
    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> render("show.json", user: user)
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "show.json", changeset: changeset)
    end
  end

  @doc false
  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "index.json", user: user)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "index.json", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.set_user_inactive(user)

    json(conn, %{status: "ok"})
  end
end
