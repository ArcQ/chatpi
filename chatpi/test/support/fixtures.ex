defmodule Chatpi.Fixtures do
  @moduledoc """
  A module for defining fixtures that can be used in tests.
  This module can be used with a list of fixtures to apply as parameter:
      use Chatpi.Fixtures, [:user]
  """
  import Chatpi.FixtureConstants

  def user do
    alias Chatpi.Users

    quote do
      @valid_attrs %{auth_key: auth_key_c, username: "some name"}

      @update_attrs %{
        username: "some updated name"
      }

      @invalid_attrs %{auth_key: nil, username: nil}

      def user_fixture(attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> Enum.into(@valid_attrs)
          |> Users.create_user()

        user
      end
    end
  end

  def chat do
    alias Chatpi.Chats
    apply(__MODULE__, :user, [])

    quote do
      @valid_attrs %{id: "some id", name: "some name", members: []}

      @update_attrs %{name: "some updated name"}

      @invalid_attrs %{id: nil, name: nil}

      def chat_fixture(attrs \\ %{}) do
        user = user_fixture()
        {:ok, chat} =
          attrs
          |> Map.update(:members, [user], &(&1 ++ [user]))
          |> Enum.into(@valid_attrs)
          |> Chats.create_chat()

        chat
      end
    end
  end

  @doc """
  Apply the `fixtures`.
  """
  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture),
      do: apply(__MODULE__, fixture, [])
  end
end
