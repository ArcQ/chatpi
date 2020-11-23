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
    resources("/", RootController, only: [:index])

    scope "/v1", V1 do
    end
  end

  # Other scopes may use custom stacks.
  scope "/api", ChatpiWeb.Api do
    pipe_through([:api, :auth, :ensure_auth])

    scope "/v1", V1 do
      resources("/users", UserController, only: [:index, :show, :create, :update])

      patch("/users/me/push_token", UserController, :add_push_token, as: :push_token)

      resources("/chats", ChatController, only: [:index, :show, :create])

      resources("/chats/:chat_id/messages", MessageController, only: [:index, :create])

      patch("/chats/:chat_id/messages/:id/seen", MessageController, :messages_seen,
        as: :message_seen
      )

      resources("/organizations", OrganizationController, except: [:new, :edit])
    end
  end
end
