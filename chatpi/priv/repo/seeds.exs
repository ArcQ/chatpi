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
alias Chatpi.{Repo, Chats.Chat, Users.User, Messages.Message, Chats.Member}

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
    name: "chat_1"
    # users: [arcq, sita]
  })

{:ok, chat_2} =
  Repo.insert(%Chat{
    id: "83cdd361-54a2-4e5a-a6db-35e20fc54555",
    name: "chat_2"
    # users: [arcq, sita, donkers]
  })

Repo.insert(%Chat{
  id: "7a6ad1d6-551c-453a-9a66-879c2587ca0d",
  name: "chat_3"
  # users: [arcq, donkers]
})

{:ok, member_1} =
  Repo.insert(%Member{
    id: "41cb74b9-db13-4931-835f-0234152bcd94",
    chat: chat_1,
    user: arcq
  })

{:ok, member_2} =
  Repo.insert(%Member{
    id: "83cdd361-54a2-4e5a-a6db-35e20fc54555",
    chat: chat_1,
    user: sita
  })

Repo.insert(%Member{
  id: "1277f9f1-6ef9-4379-8e06-c5bf12075e62",
  chat: chat_1,
  user: donkers
})

Repo.insert(%Message{
  id: "bd4333f7-7017-4b2c-ac33-d11a3abc579d",
  text: "hi this is a test mesage",
  user: arcq
})
