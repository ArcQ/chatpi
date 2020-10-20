defmodule ChatpiWeb.Api.RootController do
  @moduledoc false
  use ChatpiWeb, :controller

  @doc false
  def index(conn, _params) do
    json(conn, %{status: "ok"})
  end
end
