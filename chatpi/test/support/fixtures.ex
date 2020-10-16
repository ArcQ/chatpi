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
      @valid_attrs %{auth_key: auth_key_c(), username: "some name", is_inactive: false}

      @update_attrs %{
        username: "some updated name"
      }

      @invalid_attrs %{auth_key: nil, username: nil}

      def user_fixture(attrs \\ %{}) do
        {:ok, user} =
          attrs
          |> Enum.into(@valid_attrs)
          |> Users.create_user()
      end
    end
  end

  def chat do
    alias Chatpi.{Chats, Repo}
    alias Chatpi.Chats.{Member, Chat}

    quote do
      @valid_attrs %{id: "somechatid", name: "fixture chat 1", members: []}

      @update_attrs %{name: "some updated name"}

      @invalid_attrs %{id: nil, name: nil, members: []}

      def chat_fixture(attrs \\ %{}) do
        {:ok, user} = user_fixture()

        {:ok, chat} =
          %Chat{}
          |> Chat.changeset(Enum.into(attrs, @valid_attrs))
          |> Repo.insert()

        member = %Member{user: user, chat: chat}

        {:ok, chat} =
          chat
          |> Chats.update_chat(%{members: Enum.concat(chat.members, [member])})

        {:ok, user, chat}
      end
    end
  end

  def message do
    alias Chatpi.{Messages}

    quote do
      @valid_attrs %{text: "text", user_auth_key: nil, chat_id: nil, files: []}

      @update_attrs %{text: "updated text"}

      @invalid_attrs %{text: nil}

      def message_fixture(attrs \\ %{}) do
        {:ok, user, chat} = chat_fixture()

        new_message = Map.merge(%{user_auth_key: user.auth_key, chat_id: chat.id}, attrs)

        {:ok, message} =
          new_message
          |> Enum.into(@valid_attrs)
          |> Messages.create_message()

        {:ok, user, chat, message}
      end

      def message_fixture_reply_with_file(attrs \\ %{}) do
        {:ok, user, chat} = chat_fixture()

        new_message = Map.merge(%{user_auth_key: user.auth_key, chat_id: chat.id}, attrs)

        message =
          new_message
          |> Enum.into(@valid_attrs)
          |> Messages.create_message()
          |> (fn {:ok, message} ->
                {message,
                 %Messages.File{
                   url: "https://unsplash.com/photos/G85VuTpw6jg",
                   message: new_message
                 }}
              end).()
          |> (fn {message, file} ->
                Chats.update_message(message, %{files: Enum.concat(message.file, [file])})
              end).()

        {:ok, user, chat, message}
      end
    end
  end

  @doc """
  Apply the `fixtures`.
  """
  defmacro __using__(fixtures) when is_list(fixtures) do
    for fixture <- fixtures, is_atom(fixture), do: apply(__MODULE__, fixture, [])
  end
end
