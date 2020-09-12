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

  def call(conn, _params) do
    auth_header =
      conn
      |> get_req_header("authorization")
      |> List.first()
      |> take_prefix("Bearer ")

    case Chatpi.Auth.Token.verify_and_validate(auth_header) do
      {:ok, claims} ->
        conn
        |> Guardian.Plug.put_current_token(auth_header, [])
        |> Guardian.Plug.put_current_claims(claims, [])
        |> Guardian.Plug.put_current_resource(
          %User{
            username: claims["username"],
            auth_key: claims["sub"],
            is_inactive: false,
            messages: []
          },
          []
        )
        |> assign(:user_signed_in?, true)

      {:error, reason} ->
        conn
        |> assign(:auth_error, {:invalid_token, reason})
    end
  end
end

# TODO, we should actually have a sign in route,
# and then keep sessions through guardian instead of managing everything through jwt
defmodule Chatpi.Auth.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :chatpi,
    error_handler: Chatpi.Auth.ErrorHandler

  # plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  plug(Chatpi.Auth.VerifyHeader, claims: %{"typ" => "access"})
  # plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
end
