defmodule Chatpi.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Chatpi.{Repo, Users.User}

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(
      from(
        u in User,
        where: u.is_inactive != true
      )
    )
  end

  @doc """
  Returns the list of users with array of ids.

  ## Examples

      iex> list_users_by_ids()
      [%User{}, ...]

  """
  def list_users_by_ids(user_auth_keys) do
    Repo.all(
      from(
        u in User,
        where: u.is_inactive != true and u.auth_key in ^user_auth_keys
      )
    )
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user with token verification.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_token!("token")
      %User{}

      iex> get_user_by_token!("token")
      ** (Ecto.NoResultsError)

  """

  def get_user_by_token!(token) do
    case Chatpi.Auth.Token.verify_and_validate(token) do
      {:ok, claims} ->
        user_id = claims["sub"]
        get_user_by_auth_key!(user_id)

      {:error, _} ->
        raise Ecto.NoResultsError
    end
  end

  @doc """
  Gets a single user with auth_key verification.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by_auth_key!("auth_key")
      %User{}

      iex> get_user_by_auth_key!("auth_key")
      ** (Ecto.NoResultsError)

  """

  def get_user_by_auth_key!(auth_key) do
    Repo.get_by!(User, auth_key: auth_key)
  end

  def do_all_users_exist(auth_keys) do
    length(list_users_by_ids(auth_keys)) == length(auth_keys)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.insert_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Make a user inactive.

  ## Examples

      iex> set_user_inactive(user)
      {:ok}

      iex> set_user_inactive(user)
      {:error}

  """
  def set_user_inactive(%User{} = user) do
    user
    |> User.make_inactive_changset(%{inactive: true})
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.update_changeset(user, %{})
  end
end
