defmodule Chatpi.Auth.ErrorHandler do
  @moduledoc false

  import Phoenix.Controller

  def auth_error(conn, {type, reason}, _opts) do
    json(conn, %{error_code: type, reason: reason})
  end
end
