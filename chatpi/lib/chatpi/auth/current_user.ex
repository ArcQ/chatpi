defmodule Chatpi.Auth.CurrentUser do
  @moduledoc false
  import Plug.Conn
  alias Chatpi.Users.User

  def init(_params) do
  end

  # here we could store some user info on redis and retrieve
  def call(conn, _params) do
    claims = Guardian.Plug.current_claims(conn, [])
    if !is_nil(claims["sub"]) do
      conn
      |> Plug.Conn.assign(:current_user,
        %User{
          username: claims["sub"],
          auth_id: claims["sub"],
          is_inactive: false,
          messages: []
        })
      |> assign(:user_signed_in?, true)
    else
      conn
      |> assign(:user_signed_in?, false)
    end
  end
end
