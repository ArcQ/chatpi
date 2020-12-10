defmodule ChatpiWeb.Api.V1.UserView do
  use ChatpiWeb, :view

  @public_attributes ~W(id auth_key username)a
  @public_token_attributes ~W(id token device_id inserted_at)a

  def render("index.json", %{users: users}) do
    IO.inspect(users)
    %{
      users:
        Enum.map(users, fn user -> render_one(user, ChatpiWeb.Api.V1.UserView, "show.json") end)
    }
  end

  def render("show.json", %{user: user}) do
    user
    |> Map.take(@public_attributes)
    |> Map.put(
      :push_tokens,
      user.push_tokens
      |> Enum.map(&push_token/1)
    )
  end

  def push_token(push_token) do
    push_token
    |> Map.take(@public_token_attributes)
  end
end
