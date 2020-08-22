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
alias Chatpi.Users.User
alias Chatpi.Chats.Chat
alias Chatpi.Repo

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

Repo.insert %Chat{
  name: "chat_1",
  users: [arcq, sita],
}

Repo.insert %Chat{
  name: "chat_2",
  users: [arcq, sita, donkers],
}

Repo.insert %Chat{
  name: "chat_3",
  users: [arcq, donkers],
}
