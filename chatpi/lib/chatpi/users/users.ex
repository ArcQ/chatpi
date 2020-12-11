defmodule Chatpi.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.{Repo, Users.User, ArrayUtils}

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
        get_user_by_auth_key(auth_key)

      {:error, _} ->
        raise Ecto.NoResultsError
    end
  end

  def get_user_by_auth_key(auth_key) do
    Repo.get_by(User, auth_key: auth_key, is_inactive: false)
  end

  def get_user_by_auth_key_and_org(auth_key, organization_id) do
    case Repo.get_by(User,
           auth_key: auth_key,
           organization_id: organization_id,
           is_inactive: false
         ) do
      nil -> {:error, "entity not found"}
      user -> {:ok, user}
    end
  end

  def get_user_by_auth_key_cached(auth_key) do
    {:ok, cached_user} = Cachex.get(:users_cache, auth_key)

    if cached_user == nil do
      user = get_user_by_auth_key(auth_key)
      Cachex.put(:users_cache, auth_key, user)

      user
    else
      cached_user
    end
  end

  def add_push_token_by_auth_key(
        auth_key,
        %{token: _token, device_id: _device_id, type: _token_type} = push_token
      ) do
    user = get_user_by_auth_key(auth_key)

    push_tokens =
      user
      |> Map.get(:push_tokens)
      |> (&(&1 || [])).()
      |> ArrayUtils.add_if_unique(push_token, :device_id)

    user
    |> User.update_push_tokens_changeset(%{push_tokens: push_tokens})
    |> Repo.update()
  end

  def create_or_update_user(
        %{auth_key: auth_key, username: _username, organization: _organization} = attrs
      ) do
    case Repo.get_by(User, auth_key: auth_key) do
      nil ->
        create_user(attrs)

      user ->
        update_user(user, attrs)
    end
  end

  def create_user(attrs) do
    %User{}
    |> User.insert_changeset(Map.put(attrs, :is_inactive, false))
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  def change_user(%User{} = user) do
    User.update_changeset(user, %{})
  end
end
