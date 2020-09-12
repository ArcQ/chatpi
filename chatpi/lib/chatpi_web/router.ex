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
    # plug(Chatpi.Auth.CurrentUser)
  end

  pipeline :ensure_auth do
    plug(Guardian.Plug.EnsureAuthenticated)
  end

  scope "/api", ChatpiWeb.Api do
    pipe_through([:api])

    scope "/v1", V1 do
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", ChatpiWeb.Api do
    pipe_through([:api, :auth, :ensure_auth])

    scope "/v1", V1 do
      resources("/files", FileController, only: [:show, :create])

      resources("/users", UserController, only: [:index, :show, :create, :update])
      resources("/chats", ChatController, only: [:index, :show, :create])
      get("/chats/:chat_id/messages", MessageController, :index)

      patch("/chats/:chat_id/messages/:id/seen", MessageController, :messages_seen,
        as: :message_seen
      )
    end
  end
end
