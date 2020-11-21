defmodule ChatpiWeb.Api.V1.TokenView do
  use ChatpiWeb, :view

  @public_attributes ~W(id auth_key token, deviceId)a

  def render("show.json", %{push_token: push_token}) do
    push_token
    |> Map.take(@public_attributes)
  end
end
