defmodule ChatpiWeb.UserSocket do
  @moduledoc false
  use Phoenix.Socket
  alias Chatpi.Users

  ## Channels
  channel("chat:*", ChatpiWeb.ChatChannel)

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  def connect(params, socket) do
    # TODO use context
    #
    case Chatpi.Auth.Token.verify_and_validate(params["token"]) do
      {:ok, claims} ->
        auth_id = claims["sub"]

        IO.puts("Socket connection requested from auth_id: " <> auth_id)

        {:ok,
         socket
         |> assign(
           :user,
           Users.get_user_by_auth_id!(auth_id) |> Map.take([:id, :username, :is_inactive])
         )}

      {:error, reason} ->
        IO.puts(inspect(reason))
        {:error, reason}
    end
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     ChatpiWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  def id(_socket), do: nil
end
