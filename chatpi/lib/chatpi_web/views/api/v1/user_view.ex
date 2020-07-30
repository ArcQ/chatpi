defmodule ChatpiWeb.Api.V1.UserView do
  use ChatpiWeb, :view

  @public_attributes ~W(id auth_id username)a

  def render("index.json", %{users: users}) do
    %{
      data:
        Enum.map(users, fn user -> render_one(user, ChatpiWeb.Api.V1.UserView, "user.json") end)
    }
  end

  def render("show.json", %{user: user}) do
    %{data: render_one(user, ChatpiWeb.Api.V1.UserView, "user.json")}
  end

  def render("user.json", %{user: user}) do
    user
    |> Map.take(@public_attributes)
  end
end
