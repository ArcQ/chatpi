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
      @valid_attrs %{auth_key: auth_key_c(), username: "some name"}

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
    alias Chatpi.Chats.Member

    apply(__MODULE__, :user, [])

    quote do
      @valid_attrs %{id: "somechatid", name: "fixture chat 1", members: []}

      @update_attrs %{name: "some updated name"}

      @invalid_attrs %{id: nil, name: nil, members: []}

      def chat_fixture(attrs \\ %{}) do
        user = user_fixture()

        {:ok, chat} =
          attrs
          |> Enum.into(@valid_attrs)
          |> Chats.create_chat()

        member = %Member{user: user, chat: chat}

        # companies = chat.members ++ [member]
        #             |> Enum.map(&Ecto.Changeset.change/1)

        {:ok, chat} =
          chat
          |> Chats.update_chat(%{members: Enum.concat(chat.members, [member])})

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
