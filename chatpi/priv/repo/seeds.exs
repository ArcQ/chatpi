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
alias Chatpi.{Repo, Chats.Chat, Users.User}

Repo.transaction(fn ->
  {:ok, arcq} = Repo.insert %User{
    username: "arcq",
    auth_id: "129830df-f45a-46b3-b766-2101db28ea62",
    is_inactive: false,
    messages: []
  }

  {:ok, sita} = Repo.insert %User{
    username: "sita",
    auth_id: "5728dfb5-d089-48f1-aa9c-f1ea436fa8b1",
    is_inactive: false,
    messages: []
  }

  {:ok, donkers} = Repo.insert %User{
    username: "d0nkers",
    auth_id: "56431cd1-6724-4ac9-af64-08c74d8df027",
    is_inactive: false,
    messages: []
  }

  chat_1 = Repo.insert %Chat{
    id: 'cf4aeae1-cda7-41f3-adf7-9b2bb377be7d',
    name: "chat_1",
    users: [arcq, sita],
  }

  Repo.insert %Chat{
    id: '35e27583-a504-4d5c-a80f-99b3e658b54d ',
    name: "chat_2",
    users: [arcq, sita, donkers],
  }

  Repo.insert %Chat{
    id: '2cb426af-fe08-4168-8844-521c65e6d860 ',
    name: "chat_3",
    users: [arcq, donkers],
  }

  Repo.insert %Chat{
    id: '2cb426af-fe08-4168-8844-521c65e6d860 ',
    name: "chat_3",
    users: [arcq, donkers],
  }

  Repo.insert %Message{
    id: '2cd55c64-f3c2-4d7f-a7da-a27f56e1e713',
    text: "hi this is a test mesage",
    user: arcq,
    chat: chat_1,
  }
end)
