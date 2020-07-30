defmodule ChatpiWeb.Api.V1.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use ChatpiWeb, :controller

  def call(conn, {:error, %Ecto.Changeset{} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ChatpiWeb.ChangesetView)
    |> render("error.json", changeset: changeset)
  end

  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(ChatpiWeb.ErrorView)
    |> render(:"404")
  end

  def call(conn, {:error, :invalid_params}) do
    conn
    |> put_status(:not_found)
    |> put_view(ChatpiWeb.ErrorView)
    |> render(:"400")
  end
end
