defmodule ChatpiWeb.Api.V1.UserView do
  use ChatpiWeb, :view

  @public_attributes ~W(id auth_key username)a
  @public_token_attributes ~W(id auth_key token, deviceId)a

  def render("index.json", %{users: users}) do
    %{
      users:
        Enum.map(users, fn user -> render_one(user, ChatpiWeb.Api.V1.UserView, "show.json") end)
    }
  end

  def render("show.json", %{user: user}) do
    user
    |> Map.take(@public_attributes)
  end
end
