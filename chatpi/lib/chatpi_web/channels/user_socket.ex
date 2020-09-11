defmodule ChatpiWeb.UserSocket do
  @moduledoc false
  use Phoenix.Socket
  alias Chatpi.Users

  ## Channels
  channel("chat:*", ChatpiWeb.ChatChannel)


  defp validate_token_and_retrieve_user(token, socket) do
    case Chatpi.Auth.Token.verify_and_validate(token) do
      {:ok, claims} ->
        auth_key = claims["sub"]

        IO.puts("Socket connection requested from auth_key: " <> auth_key)

        {:ok,
          socket
          |> assign(
            :user,
            Users.get_user_by_auth_key!(auth_key) |> Map.take([:id, :username, :is_inactive])
          )}

      {:error, reason} ->
        IO.puts(inspect(reason))
        {:error, reason}
    end
  end

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
    if params["token"] != nil do
      validate_token_and_retrieve_user(params["token"], socket)
    else
      {:unauthenticated}
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
