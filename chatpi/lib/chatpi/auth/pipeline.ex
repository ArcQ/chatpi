defmodule Chatpi.Auth.Pipeline do
  @moduledoc false

  use Guardian.Plug.Pipeline,
    otp_app: :chatpi,
    error_handler: Chatpi.Auth.ErrorHandler

  # plug(Guardian.Plug.VerifySession, claims: %{"typ" => "access"})
  plug(Chatpi.Auth.VerifyHeader, claims: %{"typ" => "access"})
  # plug(Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"})
end
