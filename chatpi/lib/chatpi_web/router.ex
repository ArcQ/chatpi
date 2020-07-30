defmodule ChatpiWeb.Router do
  use ChatpiWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :auth do
    plug(Chatpi.Auth.Pipeline)
    plug(Chatpi.Auth.CurrentUser)
    plug(:put_user_token)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  scope "/", ChatpiWeb do
    pipe_through([:browser, :auth])

    get("/", RootController, :index)

    get("/users/verify/:token", UserController, :verify)
    resources("/users", UserController, only: [:index, :new, :create])
  end

  scope "/", ChatpiWeb do
    pipe_through([:browser, :auth, :ensure_auth])

    resources("/users", UserController, only: [:index, :show, :create, :update])
  end

  # Other scopes may use custom stacks.
  scope "/api", ChatpiWeb.Api do
    pipe_through(:api)

    scope "/v1", V1 do
      resources("/files", FileController, only: [:show, :create])

      resources("/users", UserController, only: [:index, :show, :create, :update])
      resources("/chats", ChatController, only: [:index, :show, :create])
      get("/messages/:id", ChatController, :messages, as: :message)
      patch("/messages/:id/seen", ChatController, :messages_seen, as: :message_seen)
    end
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      user_id_token = Phoenix.Token.sign(conn, "user_id", current_user.id)

      conn
      |> assign(:user_id, user_id_token)
    else
      conn
      |> assign(:user_id, nil)
    end
  end
end
