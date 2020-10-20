defmodule Chatpi.Auth.VerifyHeader do
  @moduledoc false
  import Plug.Conn
  alias Chatpi.Users.User

  def init(_params) do
  end

  def take_prefix(full, prefix) do
    base = byte_size(prefix)
    binary_part(full, base, byte_size(full) - base)
  end

  defp verify(auth_header, conn) do
    case Chatpi.Auth.Token.verify_and_validate(auth_header) do
      {:ok, claims} ->
        conn
        |> Guardian.Plug.put_current_token(auth_header, [])
        |> Guardian.Plug.put_current_claims(claims, [])
        |> Guardian.Plug.put_current_resource(
          %User{
            username: claims["username"],
            auth_key: claims["sub"],
            is_inactive: false
          },
          []
        )
        |> assign(:user_signed_in?, true)

      {:error, reason} ->
        conn
        |> assign(:auth_error, {:invalid_token, reason})
    end
  end

  def call(conn, _params) do
    conn
    |> get_req_header("authorization")
    |> List.first()
    |> case do
      nil ->
        conn
        |> assign(:auth_error, {:invalid_token, "authorization header not found"})

      bearer_str ->
        bearer_str
        |> take_prefix("Bearer ")
        |> verify(conn)
    end
  end
end
