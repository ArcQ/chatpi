defmodule Chatpi.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.{Repo, Users.User}

  def list_users do
    Repo.all(
      from(
        u in User,
        where: u.is_inactive == false or is_nil(u.is_inactive)
      )
    )
  end

  def list_users_by_ids(user_auth_keys \\ []) do
    Repo.all(
      from(
        u in User,
        where: u.is_inactive == false or (is_nil(u.is_inactive) and u.auth_key in ^user_auth_keys)
      )
    )
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_user_by_token!(token) do
    case Chatpi.Auth.Token.verify_and_validate(token) do
      {:ok, claims} ->
        auth_key = claims["sub"]
        get_user_by_auth_key!(auth_key)

      {:error, _} ->
        raise Ecto.NoResultsError
    end
  end

  def get_user_by_auth_key!(auth_key) do
    Repo.get_by!(User, auth_key: auth_key)
  end

  def create_or_update_user(%{auth_key: auth_key, username: _username} = attrs) do
    case Repo.get_by(User, auth_key: auth_key) do
      nil ->
        create_user(attrs)

      user ->
        update_user(user, attrs)
    end
  end

  def create_user(attrs) do
    %User{}
    |> User.insert_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def set_user_inactive(user_id) do
    %User{id: user_id}
    |> User.make_inactive_changset(%{is_inactive: true})
    |> Repo.update()
  end

  def change_user(%User{} = user) do
    User.update_changeset(user, %{})
  end
end
