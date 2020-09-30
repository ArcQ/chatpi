# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Chatpi.Repo.insert!(%Chatpi.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
#
alias Chatpi.{Repo, Chats.Chat, Users.User, Messages.Message}

defmodule MyUuid do
  def gen_uuid(str) do
    str |> Ecto.UUID.dump() |> elem(1) |> Ecto.UUID.cast() |> elem(1)
  end
end

{:ok, arcq} =
  Repo.insert(%User{
    username: "arcq",
    auth_key: "129830df-f45a-46b3-b766-2101db28ea62",
    is_inactive: false,
    messages: []
  })

{:ok, sita} =
  Repo.insert(%User{
    username: "sita",
    auth_key: "5728dfb5-d089-48f1-aa9c-f1ea436fa8b1",
    is_inactive: false,
    messages: []
  })

{:ok, donkers} =
  Repo.insert(%User{
    username: "d0nkers",
    auth_key: "56431cd1-6724-4ac9-af64-08c74d8df027",
    is_inactive: false,
    messages: []
  })

{:ok, chat_1} =
  Repo.insert(%Chat{
    id: "cf4aeae1-cda7-41f3-adf7-9b2bb377be7d",
    name: "chat_1",
    users: [arcq, sita]
  })

{:ok, chat_1} = Repo.insert(%Chat{
  id: "83cdd361-54a2-4e5a-a6db-35e20fc54555",
  name: "chat_2",
  users: [arcq, sita, donkers]
})

Repo.insert(%Chat{
  id: "7a6ad1d6-551c-453a-9a66-879c2587ca0d",
  name: "chat_3",
  users: [arcq, donkers]
})

Repo.insert(%Message{
  id: "b65fc7a7-0300-4c73-bccb-4d192ecc61c3",
  text: "hi this is a test mesage",
  user: arcq,
  chat: chat_1
})
