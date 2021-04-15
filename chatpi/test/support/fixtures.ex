defmodule Chatpi.Fixtures do
  @moduledoc """
  A module for defining fixtures that can be used in tests.
  This module can be used with a list of fixtures to apply as parameter:
      use Chatpi.Fixtures, [:user]
  """
  import Chatpi.FixtureConstants
  alias Bcrypt

  def organization do
    alias Chatpi.Organizations

    quote do
      @valid_attrs %{
        api_key: "some api key",
        api_secret_hash: Bcrypt.Base.hash_password("some api secret", Bcrypt.gen_salt(12, true)),
        name: "some org"
      }

      def organization_fixture(attrs \\ %{}) do
        {:ok, organization} =
          attrs
          |> Enum.into(@valid_attrs)
          |> Organizations.create_organization()
      end
    end
  end

  def user do
    alias Chatpi.Users

    quote do
      @valid_attrs %{auth_key: auth_key_c(), username: "some name", is_inactive: false}

      @update_attrs %{
        username: "some updated name"
      }

      @invalid_attrs %{auth_key: nil, username: nil}

      def user_fixture(attrs \\ %{}) do
        {:ok, organization} = organization_fixture()

        {:ok, user} =
          attrs
          |> Enum.into(%{organization: organization})
          |> Enum.into(@valid_attrs)
          |> Users.create_user()

        {:ok, user, organization}
      end
    end
  end

  def chat do
    alias Chatpi.{Chats, Repo}
    alias Chatpi.Chats.{Member, Chat}

    quote do
      @valid_chat_attrs %{
        id: "somechatid",
        name: "fixture chat 1",
        members: [],
        is_inactive: false
      }

      @update_chat_attrs %{name: "some updated name"}

      @invalid_attrs %{id: nil, name: nil, members: []}

      def chat_fixture(attrs \\ %{}) do
        {:ok, user, organization} = user_fixture()

        attrs =
          attrs
          |> Enum.into(@valid_chat_attrs)
          |> Enum.into(%{organization: organization})

        {:ok, chat} =
          %Chat{}
          |> Chat.changeset(attrs)
          |> Repo.insert()

        member = %Member{user: user, chat: chat}

        {:ok, chat} =
          chat
          |> Chats.update_chat(%{members: Enum.concat(chat.members, [member])})

        {:ok, user, chat, organization}
      end
    end
  end

  def message do
    alias Chatpi.{Messages, Chats, Repo}

    quote do
      @valid_attrs %{text: "text", user_auth_key: nil, chat_id: nil, files: []}

      @update_attrs %{text: "updated text"}

      @invalid_attrs %{text: nil}

      def message_fixture(attrs \\ %{}) do
        {:ok, user, chat, organization} = chat_fixture()

        new_message = Map.merge(%{user_auth_key: user.auth_key, chat_id: chat.id}, attrs)

        {:ok, message} =
          new_message
          |> Enum.into(@valid_attrs)
          |> Messages.create_message()

        {:ok, user, chat, message, organization}
      end

      def message_fixture_reply_with_file(attrs \\ %{}) do
        {:ok, user, chat, organization} = chat_fixture()

        new_message = Map.merge(%{user_auth_key: user.auth_key, chat_id: chat.id}, attrs)

        message =
          %Messages.Message{}
          |> Messages.Message.changeset(Enum.into(new_message, @valid_attrs))
          |> Repo.insert()
          |> (fn {:ok, message} ->
                %Messages.File{}
                |> Messages.File.changeset(%{
                  url: "https://unsplash.com/photos/G85VuTpw6jg",
                  message_id: message.id
                })
                |> Repo.insert()
              end).()

        {:ok, user, chat, message, organization}
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
