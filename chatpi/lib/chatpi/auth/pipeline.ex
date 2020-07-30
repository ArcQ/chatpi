defmodule Chatpi.Auth.VerifyHeader do
  @moduledoc false
  import Plug.Conn

  def init(_params) do
  end

  def call(conn, params) do
    current_user = Guardian.Plug.current_resource(conn)

    auth_header =
      conn
      |> get_req_header("authorization")
      |> List.first()

    case Chatpi.Auth.Token.verify_and_validate(auth_header) do
      {:ok, claims} ->
        {:ok,
         conn
         |> assign(:claims, claims)
         |> assign(:token, auth_header)}

      {:error, reason} ->
        Chatpi.Auth.ErrorHandler.auth_error(conn, {:invalid_token, reason}, %{})
    end

    conn
    |> assign(:current_user, current_user)
    |> assign(:user_signed_in?, !is_nil(current_user))
  end
end

defmodule Chatpi.Auth.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :chatpi,
    module: Chatpi.Guardian,
    error_handler: Chatpi.Auth.ErrorHandler

  # If there is a session token, validate it
  plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  # If there is an authorization header, validate it
  plug(Chatpi.Auth.VerifyHeader, claims: %{"typ" => "access"})
  # Load the user if either of the verifications worked
  plug(Guardian.Plug.LoadResource, allow_blank: true)
end
